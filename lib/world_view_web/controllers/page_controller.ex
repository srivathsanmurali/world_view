defmodule WorldViewWeb.PageController do
  use WorldViewWeb, :controller
  require Logger
  alias WorldView.Auth

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

    with {:ok, raw_path} <- find_page(slug),
         {:ok, body} <- File.read(raw_path),
         {:ok, html} <- render_html(body, Auth.is_dm?(conn)) do
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

  defp find_page(slug) do
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

  defp render_html(body, is_dm) do
    with lines = String.split(body, "\n"),
         {:ok, lines} <- show_dm_notes(lines, is_dm),
         {:ok, html, _} <- Earmark.as_html(lines),
         html = replace_wiki_links(html) do
      {:ok, html}
    else
      err -> err
    end
  end

  defp show_dm_notes(lines, true) do
    Enum.reject(lines, fn x ->
      Regex.match?(~r/({{{ dm|}}})/, x)
    end)
    |> case do
      [] -> {:error, "nothing to show"}
      [""] -> {:error, "nothing to show"}
      lines -> {:ok, lines}
    end
  end

  defp show_dm_notes(lines, false) do
    Enum.reduce(lines, {[], false}, fn line, {acc, dm_notes} ->
      case {line, dm_notes} do
        {"{{{ dm", _} -> {acc, true}
        {"}}}", _} -> {acc, false}
        {_line, true} -> {acc, true}
        {line, false} -> {acc ++ [line], false}
      end
    end)
    |> case do
      {[], _} -> {:error, "nothing to show"}
      {[""], _} -> {:error, "nothing to show"}
      {lines, _} -> {:ok, lines}
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
