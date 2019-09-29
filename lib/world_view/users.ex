defmodule WorldView.Users do
  use Ecto.Schema

  schema "users" do
    field :username, :string
    field :password_hash, :string
    field :is_dm, :boolean

    timestamps()
  end
end
