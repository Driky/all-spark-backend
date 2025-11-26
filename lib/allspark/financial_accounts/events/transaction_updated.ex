defmodule FinancialAccounts.Events.TransactionUpdated do
  @moduledoc """
  Event emitted when a transaction's details are modified.

  Editing historical transactions triggers recalculation of running balances
  for all subsequent transactions in the account.
  """

  @derive Jason.Encoder
  defstruct [
    :transaction_id,
    :amount,
    :transaction_date,
    :description,
    :notes,
    :category_id,
    :payee,
    :receipt_path,
    :updated_at
  ]

  @type t :: %__MODULE__{
    transaction_id: String.t(),
    amount: Decimal.t() | nil,
    transaction_date: Date.t() | nil,
    description: String.t() | nil,
    notes: String.t() | nil,
    category_id: String.t() | nil,
    payee: String.t() | nil,
    receipt_path: String.t() | nil,
    updated_at: DateTime.t()
  }
end
