use Mix.Config

# Configure your database
config :world_view, WorldView.Repo,
  username: "postgres",
  password: "postgres",
  database: "world_view_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :world_view, WorldViewWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
