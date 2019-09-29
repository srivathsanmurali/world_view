defmodule WorldViewWeb.PageController do
  use WorldViewWeb, :controller
  require Logger

  def index(conn, _params) do
    redirect(conn,
      to: Routes.page_path(conn, :page, Application.get_env(:world_view, :index_slug))
    )
  end

  def page(conn, %{"slug" => slug}) do
    slug = Slugger.slugify_downcase(slug, ?_)

    title =
      slug
      |> String.replace("_", " ")
      |> String.capitalize()

    with {:ok, raw_path} <- find_page(slug, Map.get(conn.assigns, :is_dm, false)),
         {:ok, body} <- File.read(raw_path),
         {:ok, html} <- render_html(body) do
      render(conn, "index.html", body: html, title: title)
    else
      error ->
        Logger.error(fn ->
          ~s(
          Error loading page: #{slug},
          Error: #{inspect(error)}
        )
        end)

        render_404(conn)
    end
  end

  defp find_page(slug, true) do
    raw_path =
      Application.get_env(:world_view, :raw_dir)
      |> Path.join(["dm_pages/", slug, ".md"])
      |> Path.expand()

    with true <- File.regular?(raw_path) do
      {:ok, raw_path}
    else
      false -> find_page(slug, false)
    end
  end

  defp find_page(slug, false) do
    raw_path =
      Application.get_env(:world_view, :raw_dir)
      |> Path.join(["pages/", slug, ".md"])
      |> Path.expand()

    with true <- File.regular?(raw_path) do
      {:ok, raw_path}
    else
      false -> {:error, "Can't find slug"}
    end
  end

  defp render_html(body) do
    with {:ok, html, _} <- Earmark.as_html(body),
         html = replace_wiki_links(html) do
      {:ok, html}
    else
      err -> err
    end
  end

  defp replace_wiki_links(html) do
    html
    |> String.replace(~r/\[\[.*?\]\]/, fn x ->
      x
      |> String.trim_leading("[[")
      |> String.trim_trailing("]]")
      |> wiki_link_to_url()
    end)
  end

  defp wiki_link_to_url(link) do
    slug = Slugger.slugify_downcase(link, ?_)

    WorldViewWeb.Endpoint.url()
    |> Path.join(slug)
  end

  defp render_404(conn) do
    render(conn, "index.html",
      body:
        "<h4><center>404<br>Looks like you rolled a natural 1 on your investigation.</center></h4>"
    )
  end
end
