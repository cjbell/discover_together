defmodule DT.User do
  use DT.Schema

  schema "users" do
    field :spotify_id, :string
    field :display_name, :string
    field :profile_image_url, :string
    field :spotify_access_token, :string
    field :spotify_refresh_token, :string

    timestamps
  end
  @required ~w(spotify_id display_name)
  @optional ~w(profile_image_url spotify_access_token spotify_refresh_token)

  def changeset(schema, params \\ %{}) do
    schema
    |> cast(params, @required, @optional)
  end
end
