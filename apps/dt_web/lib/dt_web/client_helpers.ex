defmodule DTWeb.ClientHelpers do
  def url() do
    "http://localhost:3000"
  end

  def auth_success_url(token) do
    url() <> "/collections?token=#{token}"
  end

  def auth_error_url(msg) do
    url() <> "/authorize?error=#{msg}"
  end
end
