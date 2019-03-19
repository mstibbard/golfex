# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :golfex,
  ecto_repos: [Golfex.Repo]

# Configures the endpoint
config :golfex, GolfexWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "jhAJFMgsal7j1nMo2uWr3Bx+NThIw344xK+IZkYwiWGmkU0nobn4Tt6YulqQdU0Q",
  render_errors: [view: GolfexWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Golfex.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
