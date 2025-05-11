defmodule Pantheon.CommandedApplication do
  @moduledoc """
  The main Commanded application for Pantheon.
  """
  use Commanded.Application,
    otp_app: :pantheon,
    event_store: [
      adapter: Commanded.EventStore.Adapters.EventStore,
      event_store: Pantheon.EventStore
    ]

  # We'll add routers as we implement bounded contexts
  router Pantheon.PatientManagement.Router
end
