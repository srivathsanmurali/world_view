defmodule WorldViewWeb.AuthController do
  use WorldViewWeb, :controller

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, auth_params) do
    case WorldView.Auth.login(auth_params) do
      {:ok, user} ->
        conn
        |> put_session(:current_user, user.id)
        |> put_flash(:info, "Logged in")
        |> redirect(to: "/")
      :error ->
        conn
        |> put_flash(:info, "Wrong email or password")
        |> render("new.html")
    end
  end

  def delete(conn, _) do
    conn
    |> delete_session(:current_user)
    |> put_flash(:info, "Logged out")
    |> redirect(to: "/")
  end
end
