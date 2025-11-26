defmodule FinancialAccounts.App do
  @moduledoc """
  Commanded application for the Financial Accounts bounded context.

  This application coordinates all command handling, event processing, and
  projections for financial account management.
  """

  use Commanded.Application,
    otp_app: :allspark,
    event_store: [
      adapter: Commanded.EventStore.Adapters.EventStore,
      event_store: FinancialAccounts.EventStore
    ]

  # Router will be defined and registered later
  # router FinancialAccounts.Router
end
