defmodule FinancialAccounts.Commands.VoidTransaction do
  @moduledoc """
  Command to void (cancel) a transaction.

  Voided transactions remain in the system but are excluded from balances.
  """

  defstruct [
    :transaction_id,
    :reason
  ]

  @type t :: %__MODULE__{
    transaction_id: String.t(),
    reason: String.t() | nil
  }
end
