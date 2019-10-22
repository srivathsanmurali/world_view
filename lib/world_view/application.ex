defmodule WorldView.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    children = [
      WorldView.Repo,
      #{Plug.Cowboy, scheme: :http, plug: Panda.Router, options: server_opts()}
    ]

    opts = [strategy: :one_for_one, name: WorldView.Supervisor]
    Supervisor.start_link(children, opts)
  end

  #defp server_opts(), do: Application.get_env(:world_view, :http, port: 4000)
end
