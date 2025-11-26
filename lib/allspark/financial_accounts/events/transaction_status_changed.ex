defmodule FinancialAccounts.Events.TransactionStatusChanged do
  @moduledoc """
  Event emitted when a transaction's status changes.

  Status changes: pending → cleared → reconciled
  Reconciled transactions cannot be edited without first being unreconciled.
  """

  @derive Jason.Encoder
  defstruct [
    :transaction_id,
    :new_status,
    :changed_at
  ]

  @type t :: %__MODULE__{
    transaction_id: String.t(),
    new_status: atom(),  # :pending | :cleared | :reconciled
    changed_at: DateTime.t()
  }
end
