use Mix.Config

config :dt, DT.Repo,
  database: "dt_dev",
  hostname: "localhost",
  pool_size: 10

config :spotify_ex,
  client_id: System.get_env("SPOTIFY_CLIENT_ID"),
  secret_key: System.get_env("SPOTIFY_SECRET_KEY"),
  user_id: "themk1boy",
  scopes: ["playlist-read-private", "playlist-modify-private"],
  callback_url: "http://localhost:4000"
