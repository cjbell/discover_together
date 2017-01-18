defmodule DTWeb.UserView do
  use DTWeb.Web, :view

  @attrs ~w(
    id
    spotify_id
    display_name
    profile_image_url
  )a

  def render("show.json", %{user: user}) do
    user
    |> Map.from_struct()
    |> Map.take(@attrs)
  end
end
