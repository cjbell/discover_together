defmodule DT.Repo.Migrations.AddPlaylistIdToContributor do
  use Ecto.Migration

  def change do
    alter table(:playlist_contributors) do
      add :spotify_playlist_id, :string
    end
  end
end
