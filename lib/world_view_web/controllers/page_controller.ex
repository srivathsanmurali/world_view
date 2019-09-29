defmodule WorldViewWeb.PageController do
  use WorldViewWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
