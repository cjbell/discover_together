defmodule DTWeb.Router do
  use DTWeb.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_auth do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
    plug Guardian.Plug.EnsureAuthenticated, handler: DTWeb.AuthController
  end

  @api_actions ~w(
    index
    show
    update
    create
    destroy
  )a

  scope "/api", DTWeb do
    pipe_through :api # Use the default api stack

    get "/login", AuthController, :login
    get "/callback", AuthController, :callback

    # Partial playlist is used for sharing before login
    get "/playlists/:id/preview", PlaylistController, :preview, as: "playlist_preview"
  end

  scope "/api", DTWeb do
    pipe_through [:api, :api_auth]

    get "/me", UserController, :me
    get "/spotify_playlists", SpotifyPlaylistController, :index

    resources "/playlists", PlaylistController, only: @api_actions do
      resources "/contributors", PlaylistContributorController, only: @api_actions, as: :contributor
    end
  end
end
