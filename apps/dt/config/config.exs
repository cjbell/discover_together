# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :dt, DT.Repo,
  adapter: Ecto.Adapters.Postgres

import_config "#{Mix.env}.exs"
