defmodule WorldView.Router do
  use Plug.Router
  require Logger

  if Mix.env() == :dev do
    use Plug.Debugger
  end

  plug Plug.Static,
    at: "/",
    from: :world_view,
    gzip: false,
    only: ~w(css)

  plug Plug.Static,
    at: "/media",
    from: Application.get_env(:world_view, :raw_dir) |> Path.join("media"),
    gzip: false

  plug Plug.Session,
    store: :cookie,
    key: "_world_view_key",
    signing_salt: "Aq0VJIoA",
    encryption_salt: "Aq0VJIoA"
  plug :put_secret_key_base

  plug(
    Plug.Parsers,
    parsers: [:urlencoded],
    pass: ["text/*"]
  )

  plug Plug.Logger, log: :debug
  plug :match
  plug :fetch_session
  plug :dispatch

  def redirect(conn, url) do
    html = Plug.HTML.html_escape(url)
    body = "<html><body>You are being <a href=\"#{html}\">redirected</a>.</body></html>"

    conn
    |> put_resp_header("location", url)
    |> Plug.Conn.resp(conn.status || 302, body)
    |> Plug.Conn.send_resp()
  end
  
  def redirect_root(conn) do
    redirect(conn, "/wiki/#{Application.get_env(:world_view, :index_slug)}")
  end

  get "/" do
    redirect_root(conn)
  end

  forward("/wiki", to: WorldView.Router.Wiki)
  forward("/auth", to: WorldView.Router.Auth)
  
  defp put_secret_key_base(conn, _opts) do
    Map.put(conn, :secret_key_base, String.duplicate("CwDs5Ej6", 8))
  end
end
