defmodule DT.PlaylistContributor do
  use DT.Schema

  schema "playlist_contributors" do
    belongs_to :contributor, DT.User
    belongs_to :playlist, DT.Playlist
    field :spotify_playlist_id, :string
    timestamps
  end
end
