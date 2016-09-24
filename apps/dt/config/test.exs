use Mix.Config

config :dt, DB.Repo,
  url: System.get_env("DATABASE_URL"),
  database: "dt_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
