defmodule DTWeb.PageController do
  use DTWeb.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
