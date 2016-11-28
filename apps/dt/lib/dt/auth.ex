defmodule DT.Auth do
  @moduledoc """
  All the auth!
  """
  alias DT.{User, Repo}
  alias Spotify, as: Sp

  @doc """
  Returns a Spotify Auth url
  """
  @spec url() :: String.t
  def url, do: Sp.Authorization.url

  @doc """
  Authenticates a user against the Spotify API and creates a
  corresponding DT.User record with the auth persisted for later use
  """
  @spec authenticate(params :: map) :: {:ok, User.t} | {:error, any}
  def authenticate(params) do
    auth = %Sp.Credentials{}

    with {:ok, %Sp.Credentials{} = sp_auth} <- Sp.Authentication.authenticate(auth, params),
         {:ok, %Sp.Profile{} = sp_profile}  <- Sp.Profile.me(sp_auth),
         {:ok, user}                        <- create_or_update_user(sp_profile, sp_auth),
         do: {:ok, user}
  end

  @doc """
  Reauthenticate a User by refreshing the auth token
  and persisting it again.
  """
  @spec reauthenticate(User.t) :: {:ok, User.t} | {:error, any}
  def reauthenticate(user) do
    user
    |> auth_from_user()
    |> Sp.Authentication.refresh()
    |> case do
      {:ok, sp_auth} -> update_user_with_auth(user, sp_auth)
      reason         -> reason
    end
  end

  @spec auth_from_user(User.t) :: Sp.Credentials.t
  def auth_from_user(%User{spotify_access_token: at, spotify_refresh_token: rt}) do
    %Sp.Credentials{access_token: at, refresh_token: rt}
  end

  defp create_or_update_user(sp_profile, sp_auth) do
    params = build_update_params(sp_profile, sp_auth)

    Repo.get_by(User, spotify_id: sp_profile.id)
    |> case do
      nil   -> %User{}
      user  -> user
    end
    |> User.changeset(params)
    |> Repo.insert_or_update()
  end

  defp update_user_with_auth(user, sp_auth) do
    params = build_update_params(sp_auth)

    user
    |> User.changeset(params)
    |> Repo.update()
  end

  defp build_update_params(sp_profile, sp_auth) do
    profile_params = build_update_params(sp_profile)
    update_params  = build_update_params(sp_auth)

    Map.merge(profile_params, update_params)
  end
  defp build_update_params(%Sp.Profile{} = profile) do
    %{display_name: profile.display_name,
      profile_image_url: extract_profile_image(profile),
      spotify_id: profile.id}
  end
  defp build_update_params(%Sp.Credentials{} = auth) do
    %{spotify_access_token: auth.access_token,
      spotify_refresh_token: auth.refresh_token}
  end

  defp extract_profile_image(%Sp.Profile{images: []}), do: nil
  defp extract_profile_image(%Sp.Profile{images: images}) do
    List.first(images)
    |> case do
      %{"url" => url} -> url
      _               -> nil
    end
  end
end
