use Mix.Config

config :dt, DT.Repo,
  database: "dt_dev",
  hostname: "localhost",
  pool_size: 10

config :spotify_ex,
  user_id: "themk1boy",
  scopes: ["playlist-read-private", "playlist-modify-private"],
  callback_url: "http://localhost:4000/callback"

import_config "dev.secret.exs"
