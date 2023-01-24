import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :satori_pubsub, SatoriPubsubWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "sSm9zG3NzsBBi2I6j0QcP6M5vWU21NHbBUtyrvmIe0+hTDmLOg2xrQqniAROYWqP",
  server: false

# In test we don't send emails.
config :satori_pubsub, SatoriPubsub.Mailer,
  adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
