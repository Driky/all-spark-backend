defmodule FinancialAccounts.Commands.DeleteTransaction do
  @moduledoc """
  Command to permanently delete a transaction.

  This is a hard delete for erroneous entries only.
  Normal corrections should use void instead.
  """

  defstruct [
    :transaction_id,
    :account_id
  ]

  @type t :: %__MODULE__{
    transaction_id: String.t(),
    account_id: String.t()
  }
end
