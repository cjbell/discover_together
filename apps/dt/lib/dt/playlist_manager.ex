defmodule DT.PlaylistManager do
  @moduledoc """
  Interface for operating on Playlists and syncing them to Spotify
  """
  alias Spotify, as: Sp
  alias DT.{Playlist, Repo, AuthManager}
  import Ecto.Query

  @doc """
  Given an owner and params, will create an **internal** representation
  of a Playlist (DT.Playlist).
  """
  @spec create() :: Ecto.Changeset.t
  def create, do: Playlist.changeset(%Playlist{})

  def create(user, params) do
    %Playlist{owner_id: user.id}
    |> Playlist.changeset(params)
    |> Repo.insert
  end

  @doc """
  Given a user, will return all playlists they are an owner of.
  """
  @spec list(User.t) :: [Playlist.t]
  def list(user) do
    from(p in Playlist, where: owner_id == ^user.id)
    |> Repo.all()
  end

  @doc """
  Given a playlist, will create it on Spotify if it doesn't already exist.
  """
  @spec create_on_spotify(Playlist.t) :: {:ok, Playlist.t} | {:error, atom | map}
  def create_on_spotify(%{owner: owner} = playlist) do
    params = build_create_params(playlist)

    with {:ok, creds}       <- AuthManager.get_creds(owner.id),
         {:ok, sp_playlist} <- Sp.Playlist.create(creds, owner.spotify_id, params),
         {:ok, playlist}    <- update_playlist(playlist, sp_playlist),
         do: {:ok, playlist}
  end

  defp build_create_params(%{name: name}), do: %{"name" => name}

  defp update_playlist(playlist, %{id: sp_id}) do
    playlist
    |> Playlist.changeset(%{spotify_id: sp_id})
    |> Repo.update
  end
end
