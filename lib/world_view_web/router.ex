defmodule WorldViewWeb.Router do
  use WorldViewWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/auth/", WorldViewWeb do
    pipe_through :browser

    get "/login", AuthController, :new
    post "/login", AuthController, :create
    delete "/login", AuthController, :delete
  end

  scope "/", WorldViewWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/:slug", PageController, :page
    get "/:folder/:page", PageController, :folder
  end
end
