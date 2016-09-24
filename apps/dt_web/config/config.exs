# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :dt_web,
  namespace: DTWeb

# Configures the endpoint
config :dt_web, DTWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Wo9VvBRKM5XPWdLMoP1bWUvTpR9PxpWrMWHNmw51tOa9ni0Mm4IFhohF73CINpzf",
  render_errors: [view: DTWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: DTWeb.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :guardian, Guardian,
  issuer: "DiscoverTogether",
  ttl: {60, :days},
  serializer: DTWeb.GuardianSerializer

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
