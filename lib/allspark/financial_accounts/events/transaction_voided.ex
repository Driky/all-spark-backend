defmodule FinancialAccounts.Events.TransactionVoided do
  @moduledoc """
  Event emitted when a transaction is voided (cancelled).

  Voided transactions remain in the system for audit purposes but are
  excluded from balance calculations.
  """

  @derive Jason.Encoder
  defstruct [
    :transaction_id,
    :reason,
    :voided_at
  ]

  @type t :: %__MODULE__{
    transaction_id: String.t(),
    reason: String.t() | nil,
    voided_at: DateTime.t()
  }
end
