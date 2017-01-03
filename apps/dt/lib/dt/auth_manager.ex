defmodule DT.AuthManager do
  @moduledoc """
  Interfacing into getting a cached set of Credentials for use
  in Spotify requests.
  """

  use GenServer
  @name __MODULE__

  def start_link() do
    GenServer.start_link(@name, [], name: @name)
  end

  @doc """
  Sets a set of Credentials to be retrieved at a later point.
  """
  @spec set_creds(number, Spotify.Credentials.t) :: no_return
  def set_creds(user_id, creds) do
    GenServer.cast(@name, {:set_creds, user_id, creds})
  end

  @doc """
  Retrieves a set of Credentials.
  """
  @spec get_creds(number) :: {:ok, Spotify.Credentials.t} | {:error, String.t}
  def get_creds(user_id) do
    GenServer.call(@name, {:get_creds, user_id})
  end

  # Callbacks

  def init(_) do
    table = :ets.new(:auth, [])
    {:ok, table}
  end

  def handle_cast({:set_creds, user_id, creds}, table) do
    set_creds(user_id, creds, table)
    {:noreply, table}
  end

  def handle_call({:get_creds, user_id}, _, table) do
    reply = get_creds(user_id, table)
    {:reply, reply, table}
  end

  defp get_creds(user_id, table) do
    {:ok, creds} = get_existing_creds(user_id, table)

    requires_refresh?(creds)
    |> case do
      true  -> refresh_and_set_creds(user_id, table)
      false -> {:ok, creds}
    end
  end

  defp set_creds(user_id, creds, table) do
    now = :os.system_time(:seconds)
    :ets.insert(table, {user_id, creds, now})
  end

  defp get_existing_creds(user_id, table) do
    :ets.lookup(table, user_id)
    |> case do
      []              -> {:ok, nil}
      [{_, creds, _}] -> {:ok, creds}
    end
  end

  # For now all cases require a refresh because TTL needs to be implemented
  defp requires_refresh?(nil), do: true
  defp requires_refresh?(_creds), do: true

  defp refresh_and_set_creds(user_id, table) do
    with {:ok, creds} <- refresh_creds(user_id),
         _            <- set_creds(user_id, creds, table),
         do: {:ok, creds}
  end

  defp refresh_creds(user_id) do
    DT.Repo.get(DT.User, user_id)
    |> DT.Auth.reauthenticate()
    |> case do
      {:ok, user} -> {:ok, DT.Auth.auth_from_user(user)}
      {:error, _} -> {:error, "There was a problem with authenticating"}
    end
  end
end
