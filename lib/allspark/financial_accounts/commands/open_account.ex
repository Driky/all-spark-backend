defmodule FinancialAccounts.Commands.OpenAccount do
  @moduledoc """
  Command to open a new financial account.

  This is the first command issued for any account and establishes
  the account with its immutable properties (type, currency).
  """

  defstruct [
    :account_id,
    :user_id,
    :name,
    :account_type,
    :base_currency
  ]

  @type t :: %__MODULE__{
    account_id: String.t(),
    user_id: String.t(),
    name: String.t(),
    account_type: atom(),
    base_currency: String.t()
  }
end
