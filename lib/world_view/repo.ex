defmodule WorldView.Repo do
  use Ecto.Repo,
    otp_app: :world_view,
    adapter: Ecto.Adapters.Postgres
end
