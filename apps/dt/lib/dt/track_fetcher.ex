defmodule DT.TrackFetcher do
  @moduledoc """
  Given a user, creds and a playlist_id knows how
  to fetch a list of tracks for that Playlist.
  """
  defmodule PartialPlaylist do
    @moduledoc """
    Describes a partial playlist that is used as a cache container
    for the tracks fetched.
    """
    defstruct id: nil,
              name: nil,
              owner_id: nil,
              tracks: [],
              snapshot_id: nil,
  end

  @spec get_tracks() :: {:ok, [Spotify.Track.t]} | {:error, atom}
  def get_tracks(user, spotify_playlist_id, creds) do
    GenServer.call(@name, {:get_tracks, user, spotify_playlist_id, creds})
  end

  def handle_call({:get_tracks, user, spotify_playlist_id, creds}, _, table) do
    reply = handle_get_tracks(user, spotify_playlist_id, creds, table)
    {:reply, reply, table}
  end

  defp handle_get_tracks(sp_id, sp_playlist_id, creds, table) do
    # Fetch the partial playlist
    # See if we have something as new in the cache
    # if not, fetch all tracks
    with {:ok, p_playlist}        <- fetch_partial_spotify_playlist(sp_id, sp_playlist_id, creds),
         {:ok, cached_p_playlist} <- get_cached_partial_playlist(p_playlist.id, table),
         {:ok, p_playlist}        <- maybe_fetch_spotify_playlist_tracks(p_playlist, cached_p_playlist, creds),
         {:ok, p_playlist}        <- update_cached_partial_playlist(p_playlist, table),
         do: {:ok, p_playlist.tracks}
  end

  defp fetch_partial_spotify_playlist(spotify_id, spotify_playlist_id, creds) do
    # We only want a few fields so we can verify the Playlist
    fields = ~w(snapshot_id name id) |> Enum.join(",")
    params = %{fields: fields}

    Spotify.Playlists.get_playlist(creds, spotify_id, spotify_playlist_id, params)
    |> case do
      {:ok, sp_playlist} -> {:ok, to_partial_playlist(sp_playlist, spotify_id)}
      err                -> err
    end
  end

  defp maybe_fetch_spotify_playlist_tracks(%{snapshot_id: sid}, %{snapshot_id: sid} = cpp, _),
    do: {:ok, cpp}
  defp maybe_fetch_spotify_playlist_tracks(partial_playlist, _, creds) do
    # Do the fetch
  end

  defp get_cached_partial_playlist(partial_playlist, table) do
    :ets.select(table, partial_playlist.id)
    |> case do
      []        -> nil
      [{id, p}] -> p
    end
  end

  defp update_cached_partial_playlist(partial_playlist, table) do
    insert = {partial_playlist.id, partial_playlist}
    :ets.new(table, insert)
    |> case do
      true  -> {:ok, partial_playlist}
      false -> {:error, :could_not_update_cache}
    end
  end

  defp to_partial_playlist(sp_playlist, owner_id) do
    attrs =
      sp_playlist
      |> Map.from_struct()
      |> Map.put(:owner_id, owner_id)

    struct(PlaylistTracks, attrs)
  end
end
