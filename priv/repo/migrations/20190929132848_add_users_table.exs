defmodule WorldView.Repo.Migrations.AddUsersTable do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :password_hash, :string
      add :is_dm, :boolean

      timestamps()
    end
  end
end
