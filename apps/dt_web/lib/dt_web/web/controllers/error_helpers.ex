defmodule DTWeb.ErrorHelpers do
  import Plug.Conn
  import Phoenix.Controller

  def render_ok(conn) do
    conn
    |> put_status(200)
    |> halt()
  end

  def render_error(conn, status_code, body \\ []) do
    conn
    |> put_status(status_code)
    |> render(DTWeb.ErrorView, to_string(status_code) <> ".json", body)
    |> halt()
  end
end
