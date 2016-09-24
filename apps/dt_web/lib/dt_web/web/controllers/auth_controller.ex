defmodule DTWeb.AuthController do
  use DTWeb.Web, :controller

  def login(conn, _) do
    redirect conn, external: DT.Auth.url
  end

  def callback(conn, params) do
    DT.Auth.authenticate(params)
    |> case do
      {:ok, user} ->
        conn
        |> Guardian.Plug.sign_in(user)
        |> redirect(to: "/playlists")
      {:error, _} ->
        conn
        |> put_flash(:error, "Could not authenticate")
        |> redirect(to: "/")
    end
  end

  def unauthenticated(conn, _) do
    conn
    |> put_status(401)
    |> put_flash(:error, "Authentication required")
    |> redirect(to: "/")
  end
end
