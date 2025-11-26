defmodule FinancialAccounts.Events.AccountOpened do
  @moduledoc """
  Event emitted when a new financial account is created.

  This event establishes the account with its basic properties including
  the account type, base currency, and user ownership.
  """

  @derive Jason.Encoder
  defstruct [
    :account_id,
    :user_id,
    :name,
    :account_type,
    :base_currency,
    :opened_at
  ]

  @type t :: %__MODULE__{
    account_id: String.t(),
    user_id: String.t(),
    name: String.t(),
    account_type: atom(),
    base_currency: String.t(),
    opened_at: DateTime.t()
  }
end
