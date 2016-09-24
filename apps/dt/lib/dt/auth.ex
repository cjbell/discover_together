defmodule DT.Auth do
  @moduledoc """
  All the auth!
  """

  @doc """
  Returns a Spotify Auth url
  """
  @spec url() :: String.t
  def url, do: Spotify.Authorization.url

  @doc """
  Authenticates a user against the Spotify API and creates a
  corresponding DT.User record with the auth persisted for later use
  """
  @spec authenticate(params :: map) :: {:ok, DT.User.t} | {:error, any}
  def authenticate(params) do
    auth = %Spotify.Auth{}

    with {:ok, sp_auth}    <- Spotify.Authentication.authenticate(auth, params),
         {:ok, sp_profile} <- Spotify.Profile.me(sp_auth),
         {:ok, user}       <- create_or_update_user(sp_profile, sp_auth),
         do: {:ok, user}
  end

  @doc """
  Reauthenticate a DT.User by refreshing the auth token
  and persisting it again.
  """
  @spec reauthenticate(DT.User.t) :: {:ok, DT.User.t} | {:error, any}
  def reauthenticate(user) do
    user
    |> auth_from_user
    |> Spotify.Authentication.refresh
    |> case do
      {:ok, sp_auth} -> update_user_with_auth(user, sp_auth)
      reason         -> reason
    end
  end

  @spec auth_from_user(DT.User.t) :: Spotify.Auth.t
  def auth_from_user(%DT.User{spotify_access_token: at, spotify_refresh_token: rt}) do
    %Spotify.Auth{access_token: at, refresh_token: rt}
  end

  defp create_or_update_user(sp_profile, sp_auth) do
    params = build_update_params(sp_profile, sp_auth)

    DT.Repo.get_by(DT.User, spotify_id: sp_profile.id)
    |> case do
      nil   -> %DT.User{}
      user  -> user
    end
    |> DT.User.changeset(params)
    |> DT.Repo.update
  end

  defp update_user_with_auth(user, sp_auth) do
    params = build_update_params(sp_auth)

    user
    |> DT.User.changeset(params)
    |> DT.Repo.update
  end

  defp build_update_params(sp_profile, sp_auth) do
    profile_params = build_update_params(sp_profile)
    update_params  = build_update_params(sp_auth)

    Map.merge(profile_params, update_params)
  end
  defp build_update_params(%Spotify.Profile{} = profile) do
    %{display_name: profile.display_name,
      profile_image_url: extract_profile_image(profile)}
  end
  defp build_update_params(%Spotify.Auth{} = auth) do
    %{spotify_access_token: auth.access_token,
      spotify_refresh_token: auth.refresh_token}
  end

  defp extract_profile_image(%Spotify.Profile{images: []}), do: nil
  defp extract_profile_image(%Spotify.Profile{images: images}) do
    List.first(images)
    |> case do
      %{url: url} -> url
      _           -> nil
    end
  end
end
