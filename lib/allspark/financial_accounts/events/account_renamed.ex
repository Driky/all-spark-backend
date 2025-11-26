defmodule FinancialAccounts.Events.AccountRenamed do
  @moduledoc """
  Event emitted when an account's name is changed.
  """

  @derive Jason.Encoder
  defstruct [
    :account_id,
    :new_name,
    :renamed_at
  ]

  @type t :: %__MODULE__{
    account_id: String.t(),
    new_name: String.t(),
    renamed_at: DateTime.t()
  }
end
