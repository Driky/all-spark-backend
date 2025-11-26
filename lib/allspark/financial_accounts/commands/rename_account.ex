defmodule FinancialAccounts.Commands.RenameAccount do
  @moduledoc """
  Command to rename an account.
  """

  defstruct [
    :account_id,
    :new_name
  ]

  @type t :: %__MODULE__{
    account_id: String.t(),
    new_name: String.t()
  }
end
