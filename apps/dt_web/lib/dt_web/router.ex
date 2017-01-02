defmodule DTWeb.Router do
  use DTWeb.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :browser_auth do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
    plug Guardian.Plug.EnsureAuthenticated, handler: DTWeb.AuthController
  end

  scope "/", DTWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/login", AuthController, :login
    get "/callback", AuthController, :callback
  end

  scope "/", DTWeb do
    pipe_through [:browser, :browser_auth]

    resources "/playlists", PlaylistController do
      resources "/contributors", PlaylistContributorController
    end
  end
end
