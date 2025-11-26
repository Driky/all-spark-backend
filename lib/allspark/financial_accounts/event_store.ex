defmodule FinancialAccounts.EventStore do
  @moduledoc """
  EventStore for the Financial Accounts bounded context.

  This event store persists all domain events for financial accounts, transactions,
  transfers, and recurring transactions. Events are never deleted, providing a
  complete audit trail of all changes.
  """

  use EventStore, otp_app: :allspark

  # Initialization is done via mix tasks:
  # mix event_store.create
  # mix event_store.init
end
