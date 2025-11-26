defmodule FinancialAccounts.Events.TransferCreated do
  @moduledoc """
  Event emitted when a transfer between accounts is created.

  A transfer creates two linked transactions:
  - Withdrawal from source account (negative amount)
  - Deposit to destination account (positive amount)

  For cross-currency transfers, includes exchange rate information.
  """

  @derive Jason.Encoder
  defstruct [
    :transfer_id,
    :user_id,
    :from_account_id,
    :to_account_id,
    :amount,
    :source_currency,
    :target_currency,
    :exchange_rate,
    :system_exchange_rate_id,
    :user_exchange_rate_id,
    :transfer_date,
    :description,
    :notes,
    :from_transaction_id,
    :to_transaction_id,
    :created_at
  ]

  @type t :: %__MODULE__{
    transfer_id: String.t(),
    user_id: String.t(),
    from_account_id: String.t(),
    to_account_id: String.t(),
    amount: Decimal.t(),
    source_currency: String.t(),
    target_currency: String.t(),
    exchange_rate: Decimal.t() | nil,
    system_exchange_rate_id: String.t() | nil,
    user_exchange_rate_id: String.t() | nil,
    transfer_date: Date.t(),
    description: String.t(),
    notes: String.t() | nil,
    from_transaction_id: String.t(),
    to_transaction_id: String.t(),
    created_at: DateTime.t()
  }
end
