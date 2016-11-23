defmodule DT.Repo.Migrations.CreatePlaylistContributors do
  use Ecto.Migration

  def change do
    create table(:playlist_contributors) do
      add :contributor_id, references(:users)
      add :playlist_id, references(:playlists)
      timestamps
    end
    create unique_index(:playlist_contributors, [:contributor_id, :playlist_id], name: :playlist_contributor)
  end
end
