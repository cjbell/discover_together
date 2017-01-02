defmodule DT.ContributorManager do
  @moduledoc """
  Interface for managing members of a Playlist.
  """
  alias DT.{Playlist, PlaylistContributor, User}

  @doc """
  Joins the spcified playlist
  """
  def join(playlist, user) do
    with {:ok, user_creds}  <- get_creds(user),
         {:ok, owner_creds} <- get_creds(playlist.owner),
         {:ok, playlist}    <- join_playlist(playlist, user),
         {:ok, playlist}    <- write_playlist(playlist, owner_creds),
         {:ok, playlist}    <- follow_playlist(playlist, user_creds),
         do: {:ok, playlist}
  end

  @doc """
  Leaves the spcified playlist
  """
  def leave(playlist, user) do
    with {:ok, user_creds}  <- get_creds(user),
         {:ok, owner_creds} <- get_creds(playlist.owner),
         {:ok, playlist}    <- leave_playlist(playlist, user),
         {:ok, playlist}    <- write_playlist(playlist, owner_creds),
         {:ok, playlist}    <- unfollow_playlist(playlist, user, user_creds),
         do: {:ok, playlist}
  end

  defp get_creds(user) do
    DT.AuthManager.get_creds(user.id)
  end

  defp join_playlist(playlist, user) do
    # Adds the contributor
  end

  defp leave_playlist(playlist, user) do
    # Removes the contributor
  end

  defp write_playlist(playlist, owner_creds) do
    DT.PlaylistWriter.write_playlist(playlist, owner_creds)
  end

  defp follow_playlist(playlist, user, user_creds) do
    DT.PlaylistFollower.follow_playlist(playlist, user, user_creds)
  end

  defp unfollow_playlist(playlist, user, user_creds) do
    DT.PlaylistFollower.unfollow_playlist(playlist, user, user_creds)
  end
end
