defmodule FinancialAccounts.Events.TransactionDeleted do
  @moduledoc """
  Event emitted when a transaction is permanently deleted.

  This is a hard delete that removes the transaction from the account.
  Should only be used for erroneous entries, not for normal corrections.
  """

  @derive Jason.Encoder
  defstruct [
    :transaction_id,
    :account_id,
    :deleted_at
  ]

  @type t :: %__MODULE__{
    transaction_id: String.t(),
    account_id: String.t(),
    deleted_at: DateTime.t()
  }
end
