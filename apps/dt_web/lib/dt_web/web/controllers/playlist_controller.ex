defmodule DTWeb.PlaylistController do
  use DTWeb.Web, :controller

  def index(conn, params) do
    user      = Guardian.Plug.current_resource(conn)
    playlists = DT.PlaylistManager.list(user)
    render(conn, "index.html", playlists: playlists)
  end

  def new(conn, params) do
    changeset = DT.PlaylistManager.create()
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, params) do
    user = Guardian.Plug.current_resource(conn)
    DT.PlaylistManager.create(user, params)
    |> case do
      {:ok, playlist} ->
        conn
        |> put_flash(:success, "Playlist created")
        |> redirect(to: playlist_path(conn, :show, playlist.id))
      {:error, changeset} ->
        conn
        |> render(conn, "new.html", changeset: changeset)
    end
  end
end
