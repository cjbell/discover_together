defmodule DTWeb.PlaylistController do
  use DTWeb.Web, :controller

  def index(conn, params) do
    user      = Guardian.Plug.current_resource(conn)
    playlists = DT.PlaylistManager.list(user)
    render(conn, "index.json", playlists: playlists)
  end

  def preview(conn, %{"id" => id}) do
    DT.PlaylistManager.get_playlist_preview(id)
    |> case do
      %DT.Playlist{} = playlist ->
        render(conn, "preview.json", playlist: playlist)
      _ ->
        render_error(conn, 404)
    end
  end

  def create(conn, params) do
    user = Guardian.Plug.current_resource(conn)
    DT.PlaylistManager.create(user, params)
    |> case do
      {:ok, playlist} ->
        render(conn, "show.json", playlist: playlist)
      {:error, changeset} ->
        render_error(conn, 422, changeset: changeset)
    end
  end
end
