defmodule FinancialAccounts.Commands.CreateTransfer do
  @moduledoc """
  Command to create a transfer between two accounts.

  For cross-currency transfers, can optionally override the exchange rate
  to account for fees or different rates than market rate.
  """

  defstruct [
    :transfer_id,
    :user_id,
    :from_account_id,
    :to_account_id,
    :amount,
    :transfer_date,
    :description,
    :notes,
    :exchange_rate_override
  ]

  @type t :: %__MODULE__{
    transfer_id: String.t(),
    user_id: String.t(),
    from_account_id: String.t(),
    to_account_id: String.t(),
    amount: Decimal.t(),
    transfer_date: Date.t(),
    description: String.t() | nil,
    notes: String.t() | nil,
    exchange_rate_override: Decimal.t() | nil
  }
end
