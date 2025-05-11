ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Pantheon.Repo, :manual)

# Ensure EventStore is properly initialized for testing
if System.get_env("CI") != "true" do
  # Reset EventStore database
  Mix.Task.run("event_store.drop", ["--quiet"])
  Mix.Task.run("event_store.create", ["--quiet"])
  Mix.Task.run("event_store.init", ["--quiet"])
end
