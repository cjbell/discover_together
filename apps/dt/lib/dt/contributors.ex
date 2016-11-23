defmodule DT.Contributors do
  alias DT.{Playlist, PlaylistContributor, User}

  @doc """
  Joins the spcified playlist
  """
  def join(playlist, user) do
    # with {:ok, contrib}  <- join_playlist(playlist, user),
    #{:ok, playlist} <- maybe_create_spotify_playlist(playlist),
    #     {:ok, _}        <- sync_playlist(:added_user, playlist, user),
    #     {:ok, _}        <- follow_playlist(playlist, user),
    #     do: {:ok, playlist, user}
  end

  @doc """
  Leaves the spcified playlist
  """
  def leave(playlist, user) do

  end

  defp maybe_create_spotify_playlist(%Playlist{spotify_id: nil} = playlist) do
    DT.PlaylistManager.create_on_spotify(playlist)
  end
  defp maybe_create_spotify_playlist(playlist), do: {:ok, playlist}
end
