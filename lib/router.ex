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


  plug(Plug.Logger, log: :debug)
  plug(:match)
  plug(:dispatch)

  get "/" do
    Wiki.render_wiki(Application.get_env(:world_view, :index_slug), conn)
  end

  forward("/wiki", to: WorldView.Router.Wiki)
end
