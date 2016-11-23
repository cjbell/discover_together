defmodule DT.Repo.Migrations.CreatePlaylists do
  use Ecto.Migration

  def change do
    create table(:playlists) do
      add :spotify_id, :string
      add :name, :string
      add :owner_id, references(:users)

      timestamps
    end
  end
end
