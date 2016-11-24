defmodule DT.AuthManager do
  use GenServer
  @name __MODULE__

  def start_link() do
    GenServer.start_link(@name, [], name: @name)
  end

  def set_creds(user_id, creds) do
    GenServer.cast(@name, {:set_creds, user_id, creds})
  end

  def get_creds(user_id) do
    GenServer.call(@name, {:get_creds, user_id})
  end

  # Callbacks

  def init(_) do
    table = :ets.new(:auth, [])
    {:ok, table}
  end

  def handle_cast({:set_creds, user_id, creds}, table) do
    do_set_creds(user_id, creds, table)
    {:noreply, table}
  end

  def handle_call({:get_creds, user_id}, _, table) do
    reply = do_get_creds(user_id, table)
    {:reply, reply, table}
  end

  defp do_get_creds(user_id, table) do
    with {:ok, creds} <- get_creds(user_id, table),
         {:ok, creds} <- maybe_refetch_creds(creds, user_id),
         {:ok, creds} <- maybe_refresh_creds(creds),
         _            <- do_set_creds(user_id, creds, table) do 
      {:ok, creds}
    else 
      _ -> {:error, :no_creds}
    end
  end

  defp do_set_creds(user_id, creds, table) do
    now = :os.system_time(:seconds)
    :ets.insert(table, {user_id, creds, now})
  end

  defp get_creds(user_id, table) do
    :ets.lookup(table, user_id)
    |> case do
      []     -> {:ok, nil} 
      [item] -> {:ok, item}
    end |> IO.inspect
  end

  defp maybe_refetch_creds({_, creds, ts}, _), do: {:ok, {creds, ts}}
  defp maybe_refetch_creds(nil, user_id) do
    # We don't have this users credentials in the cache: refetch!
    creds =
      DT.Repo.get(DT.User, user_id)
      |> DT.Auth.auth_from_user()

    # Don't set a time so we always refresh these
    {:ok, {creds, nil}}
  end

  defp maybe_refresh_creds({creds, _}) do
    # Always refresh, for now
    Spotify.Authentication.refresh(creds)
  end
end
