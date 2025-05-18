# test/support/storage.ex
defmodule Pantheon.Storage do

  alias EventStore.Storage.Initializer
  @doc """
  Clear the event store and read store databases
  """
  def reset! do
    reset_eventstore()
  end

  defp reset_eventstore do
    config = Pantheon.EventStore.config()

    {:ok, conn} = Postgrex.start_link(config)

    EventStore.Storage.Initializer.reset!(conn, config)

    Initializer.reset!(conn, config)
  end
end
