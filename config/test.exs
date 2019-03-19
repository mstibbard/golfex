use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :golfex, GolfexWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :golfex, Golfex.Repo,
  username: "postgres",
  password: "postgres",
  database: "golfex_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :pbkdf2_elixir, :rounds, 1
