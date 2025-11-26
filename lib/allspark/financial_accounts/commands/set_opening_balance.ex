defmodule FinancialAccounts.Commands.SetOpeningBalance do
  @moduledoc """
  Command to set or update the opening balance for an account.

  The opening balance establishes the anchor point for all transaction
  tracking. It can be updated if needed (e.g., user discovers earlier
  verified balance), which will trigger recalculation of all running balances.
  """

  defstruct [
    :account_id,
    :balance,
    :as_of_date
  ]

  @type t :: %__MODULE__{
    account_id: String.t(),
    balance: Decimal.t(),
    as_of_date: Date.t()
  }
end
