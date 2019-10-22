defmodule WorldView.MixProject do
  use Mix.Project

  def project do
    [
      app: :world_view,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [
      mod: {WorldView.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:plug_cowboy, "~> 2.0"},
      {:ecto, "~> 3.0"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, "~> 0.14"},
      {:eex_html, "~> 1.0.0"},
      {:earmark, "~> 1.3"},
      {:slugger, "~> 0.3.0"},
      {:bcrypt_elixir, "~> 2.0"},

    ]
  end
  
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"]
    ]
  end
end
