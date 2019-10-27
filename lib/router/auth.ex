defmodule WorldView.Router.Auth do
  use Plug.Router
  require Logger
  alias WorldView.Auth
  alias WorldView.Router.Wiki
  
  plug :match
  plug :dispatch

  @login_path :code.priv_dir(:world_view) |> Path.join("templates/auth_login.html.eex")

  get "/login" do
    conn
    |> Plug.Conn.resp(200, EEx.eval_file(@login_path))
    |> Plug.Conn.send_resp()
  end
  
  post "/login" do
    conn
    |> Map.get(:body_params)
    |> Auth.login()
    |> case do
      {:ok, user} ->
        conn
        |> put_session(:current_user, user.id)
        |> Wiki.render_root()
      :error ->
        conn
        |> Plug.Conn.resp(200, EEx.eval_file(@login_path))
        |> Plug.Conn.send_resp()
    end
  end
  
  get "/logout" do
    conn
    |> IO.inspect()
    |> delete_session(:current_user)
    |> Wiki.render_root()
  end
  
  match _ do
    conn
    |> Wiki.render_root()
  end

  def current_user(conn) do
    conn
    |> Plug.Conn.fetch_session
    |> Plug.Conn.get_session(:current_user)
    |> case do
      nil -> nil
      id -> WorldView.Repo.get(WorldView.Users, id)
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
