import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :allspark, Allspark.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "allspark_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :allspark, AllsparkWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "P+6w/b491fsdik2Vqp8/F4Zq6/5YdlrtQ6MR7zMFHyenS72aolUAps8qJ4PMwtXC",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

# Email redirect configuration for Supabase auth
config :allspark, :email_redirect_to, "http://localhost:3000/login"

# Event Store configuration for testing
config :allspark, FinancialAccounts.EventStore,
  serializer: EventStore.JsonbSerializer,
  username: "postgres",
  password: "postgres",
  database: "allspark_eventstore_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool_size: System.schedulers_online() * 2,
  pool: Ecto.Adapters.SQL.Sandbox

# Commanded test configuration
config :allspark, FinancialAccounts.App,
  event_store: [
    adapter: Commanded.EventStore.Adapters.EventStore,
    event_store: FinancialAccounts.EventStore
  ],
  pubsub: :local,
  registry: :local

# Oban test configuration (testing mode)
config :allspark, Oban, testing: :inline
