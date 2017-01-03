defmodule DT.PlaylistWriter do
  @moduledoc """
  Exposes the ability to take a `DT.Playlist` with `DT.PlaylistContributors`
  and will write out the most up-to-date `Spotify.Playlist` with the
  contributors tracks.
  """
  alias DT.{AuthManager, TrackFetcher}

  @doc """
  Write a Spotify Playlist from a `DT.Playlist`. If the Playlist does not yet
  exist on Spotify (the `spotify_playlist_id` is nil) the Playlist will be
  created on spotify first.
  """
  def write_playlist(playlist, owner_creds) do
    with {:ok, playlist, sp_playlist} <- create_spotify_playlist(playlist, owner_creds),
         {:ok, tracks}                <- collate_contributor_tracks(playlist),
         {:ok, sp_playlist}           <- clear_spotify_playlist(sp_playlist, owner_creds),
         {:ok, sp_playlist}           <- update_spotify_playlist(sp_playlist, tracks, owner_creds),
         {:ok, playlist}              <- log_mutations(playlist, sp_playlist, tracks),
         do: {:ok, playlist}
  end

  defp collate_contributor_tracks(%{contributors: contributors}) do
    result =
      Enum.map(contributors, &fetch_contributor_tracks(&1))
      
  end

  defp fetch_contributor_tracks(%{spotify_playlist_id: sp_playlist_id, contributor: user}) do
    with {:ok, creds}  <- AuthManager.get_creds(user.id),
         {:ok, tracks} <- TrackFetcher.get_tracks(user, sp_laylist_id, creds),
         do {:ok, tracks}
  end
end
