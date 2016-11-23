defmodule DT.Playlist do
  use DT.Schema

  schema "playlists" do
    field :spotify_id, :string
    field :name, :string
    belongs_to :owner, DT.User

    timestamps
  end
  @required ~w(spotify_id name)
  @optional ~w()

  def changeset(schema, params \\ %{}) do
    schema
    |> cast(params, @required, @optional)
  end
end
