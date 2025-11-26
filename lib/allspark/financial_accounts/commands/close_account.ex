defmodule FinancialAccounts.Commands.CloseAccount do
  @moduledoc """
  Command to close an account.

  Closing an account prevents new transactions but preserves
  all historical data for reporting purposes.
  """

  defstruct [
    :account_id,
    :reason
  ]

  @type t :: %__MODULE__{
    account_id: String.t(),
    reason: String.t() | nil
  }
end
