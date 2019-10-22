use Mix.Config

config :world_view,
  ecto_repos: [WorldView.Repo]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

import_config "#{Mix.env()}.exs"
