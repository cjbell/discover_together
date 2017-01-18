defmodule DTWeb.SpotifyPlaylistController do
  use DTWeb.Web, :controller

  def index(conn, _) do
    user = Guardian.Plug.current_resource(conn)

    DT.Playlists.get_all_spotify_playlists(user)
    |> case do
      {:ok, playlists} ->
        render(conn, DTWeb.SpotifyPlaylistView, "index.json", playlists: playlists)
      {:error, error_reason} ->
        render_error(conn, 422, error_reason)
    end
  end

  def render_error(conn, status, reason) do
    # TODO: implement!
  end

end
