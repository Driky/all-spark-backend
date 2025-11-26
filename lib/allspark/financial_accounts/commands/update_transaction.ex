defmodule FinancialAccounts.Commands.UpdateTransaction do
  @moduledoc """
  Command to update an existing transaction's details.

  Reconciled transactions must be unreconciled before editing.
  Changes to amount or date trigger balance recalculation.
  """

  defstruct [
    :transaction_id,
    :amount,
    :transaction_date,
    :description,
    :notes,
    :category_id,
    :payee,
    :receipt_path
  ]

  @type t :: %__MODULE__{
    transaction_id: String.t(),
    amount: Decimal.t() | nil,
    transaction_date: Date.t() | nil,
    description: String.t() | nil,
    notes: String.t() | nil,
    category_id: String.t() | nil,
    payee: String.t() | nil,
    receipt_path: String.t() | nil
  }
end
