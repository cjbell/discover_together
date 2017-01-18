defmodule DTWeb.UserController do
  use DTWeb.Web, :controller

  def me(conn, _) do
    user = Guardian.Plug.current_resource(conn)
    render(conn, DTWeb.UserView, "show.json", user: user)
  end
end
