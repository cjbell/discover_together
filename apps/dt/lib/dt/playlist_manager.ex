defmodule DT.PlaylistManager do

  @spec create() :: Ecto.Changeset.t
  def create, do: DT.Playlist.changeset(%DT.Playlist{})

  def create(user, params) do
    %DT.Playlist{owner_id: user.id}
    |> DT.Playlist.changeset(params)
    |> DT.Repo.insert
  end

  def create_on_spotify(playlist) do
    params = build_create_params(playlist)

    with {:ok, creds}    <- DT.AuthManager.credentials(playlist.owner),
         {:ok, playlist} <- do_create_on_spotify(creds, playlist),
         do: {:ok, playlist}
  end

  defp do_create_on_spotify(creds, %{owner: owner} = playlist) do
    params = build_create_params(playlist)

    Spotify.Playlist.create(creds, owner.spotify_id, params)
    |> case do
      {:ok, sp_playlist} ->
        playlist
        |> Playlist.changeset(%{spotify_id: sp_playlist.id})
        |> Repo.update

      error -> error
    end
  end

  defp build_create_params(%{name: name}), do: %{"name" => name}
end
