defmodule WorldView.Router.Wiki do
  use Plug.Router
  require Logger
  alias WorldView.Router.Auth

  plug(:match)
  plug(:dispatch)

  match _ do
    conn.path_info
    |> Enum.join("/")
    |> render_wiki(conn)
  end

  @template_path :code.priv_dir(:world_view) |> Path.join("templates/wiki.html.eex")

  defp render_wiki(slug, conn) do
    title =
      slug
      |> String.replace("_", " ")
      |> String.capitalize()

    raw_path =
      Application.get_env(:world_view, :raw_dir)
      |> Path.join(["pages/", slug, ".md"])
      |> Path.expand()

    with {:ok, body} <- File.read(raw_path),
         {:ok, html} <- render_html(body, Auth.is_dm?(conn)) do
      html =
        EEx.eval_file(@template_path,
          assigns: [body: html, title: title, current_user: Auth.current_user(conn)]
        )

      conn
      |> Plug.Conn.resp(200, html)
      |> Plug.Conn.send_resp()
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

  defp render_html(body, is_dm) do
    with lines = String.split(body, "\n"),
         {:ok, lines} <- show_dm_notes(lines, is_dm),
         {:ok, html, _} <- Earmark.as_html(lines) do
      {:ok, replace_wiki_links(html)}
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

  defp render_404(conn) do
    html =
      "<h4><center>404<br>Looks like you rolled a natural 1 on your investigation.</center></h4>"

    conn
    |> Plug.Conn.resp(404, html)
    |> Plug.Conn.send_resp()
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
    Path.join("/wiki/", link)
  end
end
