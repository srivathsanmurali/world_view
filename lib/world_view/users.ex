defmodule WorldView.Users do
  use Ecto.Schema
  import Ecto.Changeset
  alias WorldView.Repo

  schema "users" do
    field :username, :string
    field :password_hash, :string
    field :is_dm, :boolean

    field :password, :string, virtual: true

    timestamps()
  end

  def create(username, password, is_dm \\ false) do
    %__MODULE__{}
    |> cast(%{username: username, password: password, is_dm: is_dm}, [
      :username,
      :password,
      :is_dm
    ])
    |> validate_required([:username, :password, :is_dm])
    |> validate_format(:username, ~r/^[[:alnum:]]+$/)
    |> validate_length(:password, min: 5)
    |> hash_password()
    |> Repo.insert()
  end

  defp hash_password(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset), 
    do: put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))

  defp hash_password(changeset), do: changeset

  def all(), do: Repo.all(__MODULE__)
end
