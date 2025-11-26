defmodule FinancialAccounts.Commands.RecordTransaction do
  @moduledoc """
  Command to record a new transaction in an account.

  Transactions must be dated on or after the account's opening balance date.
  """

  defstruct [
    :transaction_id,
    :account_id,
    :user_id,
    :amount,
    :currency,
    :transaction_date,
    :description,
    :notes,
    :category_id,
    :payee,
    :status,
    :receipt_path
  ]

  @type t :: %__MODULE__{
    transaction_id: String.t(),
    account_id: String.t(),
    user_id: String.t(),
    amount: Decimal.t(),
    currency: String.t(),
    transaction_date: Date.t(),
    description: String.t(),
    notes: String.t() | nil,
    category_id: String.t() | nil,
    payee: String.t() | nil,
    status: atom(),  # :pending | :cleared | :reconciled
    receipt_path: String.t() | nil
  }
end
