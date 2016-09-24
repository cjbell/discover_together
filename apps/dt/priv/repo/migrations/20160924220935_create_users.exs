defmodule DT.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :spotify_id, :string
      add :display_name, :string
      add :profile_image_url, :string
      add :spotify_access_token, :string
      add :spotify_refresh_token, :string

      timestamps
    end
    create unique_index(:users, [:spotify_id])
  end
end
