defmodule DTWeb.SpotifyPlaylistView do
  use DTWeb.Web, :view
  @attrs ~w(
    id
    name
    owner
    snapshot_id
  )a

  def render("index.json", %{playlists: playlists}) do
    render_many(playlists, __MODULE__, "show.json")
    |> wrap_response("playlists")
  end

  def render("show.json", %{playlist: playlist}) do
    playlist
    |> Map.from_struct()
    |> Map.take(@attrs)
  end

  def wrap_response(map, name) do
    Map.new() |> Map.put(name, map)
  end
end
