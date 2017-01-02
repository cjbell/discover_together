defmodule DT.PlaylistManager do
  @moduledoc """
  Interface for operating on Playlists and syncing them to Spotify
  """
  alias Spotify, as: Sp
  alias DT.{User, Playlist, Repo, AuthManager}
  import Ecto.Query

  @doc """
  Finds a playlist by the given id and preloads
  associated data.
  """
  def find_by_id(id) do
    Repo.get(Playlist, id)
    |> with_preload()
  end

  @doc """
  Given an owner and params, will create an **internal** representation
  of a Playlist (DT.Playlist).
  """
  @spec create() :: Ecto.Changeset.t
  def create(), do: Playlist.changeset(%Playlist{})

  @spec create(User.t, map) :: {:ok, Playlist.t} | {:error, Ecto.Changeset.t}
  def create(user, params) do
    %Playlist{owner_id: user.id}
    |> Playlist.changeset(params)
    |> Repo.insert()
  end

  @doc """
  Given a user, will return all playlists they are an owner of.
  """
  @spec list(User.t) :: [Playlist.t]
  def list(user) do
    from(p in Playlist, where: p.owner_id == ^user.id)
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
         {:ok, playlist}    <- update_playlist_with_spotify_id(playlist, sp_playlist),
         do: {:ok, playlist}
  end

  @doc """
  Given a playlist, or a list of Playlists will preload
  associated data for the Playlist(s).
  """
  def with_preload(playlist), do: with_preload(playlist, :full)

  def with_preload(nil, _), do: nil
  def with_preload([], _), do: []
  def with_preload(playlist_or_playlists, :full) do
    playlist_or_playlists
    |> Repo.preload([:owner, contributors: [:contributor]])
  end
  def with_preload(playlist_or_playlists, :partial) do
    playlist_or_playlists
    |> Repo.preload([:owner])
  end

  defp build_create_params(%{name: name}), do: %{"name" => name}

  defp update_playlist_with_spotify_id(playlist, %{id: sp_id}) do
    playlist
    |> Playlist.changeset(%{spotify_id: sp_id})
    |> Repo.update()
  end
end
