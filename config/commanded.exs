# config/commanded.exs - CORRECTED VERSION
import Config

config :commanded,
  event_store_adapter: Commanded.EventStore.Adapters.EventStore

config :pantheon, Pantheon.CommandedApplication,
  event_store: [
    adapter: Commanded.EventStore.Adapters.EventStore,
    event_store: Pantheon.EventStore
  ],
  pubsub: :local,
  registry: :local

config :pantheon, Pantheon.EventStore,
  serializer: Commanded.Serialization.JsonSerializer,
  username: "postgres",
  password: "postgres",
  database: "pantheon_eventstore_#{config_env()}",
  hostname: "localhost",
  pool_size: 10
