defmodule DTWeb.AuthController do
  use DTWeb.Web, :controller
  import DTWeb.ClientHelpers, only: [auth_success_url: 1, auth_error_url: 1]

  def login(conn, _) do
    redirect conn, external: DT.Auth.url()
  end

  def callback(conn, params) do
    DT.Auth.authenticate(params)
    |> case do
      {:ok, user} ->
        conn  = Guardian.Plug.api_sign_in(conn, user)
        token = Guardian.Plug.current_token(conn)
        conn
        |> redirect(to: auth_success_url(token))
      {:error, _} ->
        conn
        |> redirect(to: auth_error_url("Could not authenticate"))
    end
  end

  def unauthenticated(conn, _) do
    conn
    |> redirect(to: auth_error_url("Could not authenticate"))
  end
end
