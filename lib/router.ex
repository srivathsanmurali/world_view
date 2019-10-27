defmodule WorldView.Router do
  use Plug.Router
  require Logger
  alias WorldView.Router.Wiki

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


  get "/" do
    Wiki.render_root(conn)
  end

  forward("/wiki", to: WorldView.Router.Wiki)
  forward("/auth", to: WorldView.Router.Auth)
  
  defp put_secret_key_base(conn, _opts) do
    Map.put(conn, :secret_key_base, String.duplicate("CwDs5Ej6", 8))
  end
end
