defmodule FinancialAccounts.Events.TransactionRecorded do
  @moduledoc """
  Event emitted when a new transaction is recorded in an account.

  This is the primary event for tracking financial activity. Each transaction
  affects the account's running balance and is assigned a sequence number
  for proper ordering.
  """

  @derive Jason.Encoder
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
    :receipt_path,
    :recorded_at
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
    receipt_path: String.t() | nil,
    recorded_at: DateTime.t()
  }
end
