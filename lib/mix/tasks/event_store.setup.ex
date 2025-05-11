# lib/mix/tasks/event_store.setup.ex
defmodule Mix.Tasks.EventStore.Setup do
  @moduledoc """
  Sets up the EventStore database.
  """
  use Mix.Task

  @shortdoc "Sets up the EventStore database"
  def run(_args) do
    # Start necessary applications
    [:postgrex, :ssl]
    |> Enum.each(&Application.ensure_all_started/1)

    # Create and initialize EventStore databases
    create_and_init_eventstore(:dev)
    create_and_init_eventstore(:test)

    IO.puts("EventStore databases setup successfully!")
  end

  defp create_and_init_eventstore(env) do
    # Load environment-specific configuration
    Mix.env(env)
    Mix.Task.run("app.config")

    # Create and initialize EventStore
    IO.puts("Setting up EventStore for #{env} environment...")
    Mix.Task.run("event_store.create", ["--quiet"])
    Mix.Task.run("event_store.init", ["--quiet"])
  end
end
