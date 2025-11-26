defmodule FinancialAccounts.Events.OpeningBalanceSet do
  @moduledoc """
  Event emitted when the opening balance is set for an account.

  This establishes the anchor point for all transaction tracking. The opening
  balance date determines the minimum date for all transactions in this account.
  All running balance calculations start from this point.
  """

  @derive Jason.Encoder
  defstruct [
    :account_id,
    :balance,
    :as_of_date,
    :set_at
  ]

  @type t :: %__MODULE__{
    account_id: String.t(),
    balance: Decimal.t(),
    as_of_date: Date.t(),
    set_at: DateTime.t()
  }
end
