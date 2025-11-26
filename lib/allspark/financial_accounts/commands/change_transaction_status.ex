defmodule FinancialAccounts.Commands.ChangeTransactionStatus do
  @moduledoc """
  Command to change a transaction's status.

  Status workflow: pending → cleared → reconciled
  Can also go backwards: reconciled → cleared → pending
  """

  defstruct [
    :transaction_id,
    :new_status
  ]

  @type t :: %__MODULE__{
    transaction_id: String.t(),
    new_status: atom()  # :pending | :cleared | :reconciled
  }
end
