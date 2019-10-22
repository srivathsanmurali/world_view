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

  defp get_user(username) do
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

  def current_user(conn) do
    case Plug.Conn.get_session(conn, :current_user) do
      nil -> nil
      id -> Repo.get(Users, id)
    end
  end

  def logged_in?(conn), do: !!current_user(conn)

  def is_dm?(conn) do
    case current_user(conn) do
      nil -> false
      user -> user.is_dm
    end
  end
end
