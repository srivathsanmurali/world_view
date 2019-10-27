defmodule WorldView.Auth do
  alias WorldView.{Users,Repo}

  def login(params) do
    with {:ok, user} <- get_user(params["username"]),
         :ok <- authenticate(user, params["password"]) do
      {:ok, user}
    else
      _ -> :error
    end
  end

  def get_user(username) do
    case Repo.get_by(Users, username: username) do
      nil -> :error
      user -> {:ok, user}
    end
  end

  defp authenticate(user, password) do
    case Bcrypt.verify_pass(password, user.password_hash) do
      true -> :ok
      _ -> :error
    end
  end
end
