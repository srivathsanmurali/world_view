use Mix.Config

config :world_view, WorldView.Repo,
  username: "postgres",
  password: "postgres",
  database: "world_view_dev",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :world_view, 
  http: [port: 4000]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

config :world_view,
  raw_dir: "/home/sri/code/ryk/",
  index_slug: "ryk",
  world_name: "Ryk"
