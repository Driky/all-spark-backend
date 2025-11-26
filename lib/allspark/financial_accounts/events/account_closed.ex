defmodule FinancialAccounts.Events.AccountClosed do
  @moduledoc """
  Event emitted when an account is closed/deactivated.

  Closed accounts are soft-deleted - they remain in the system for
  historical reporting but cannot have new transactions added.
  """

  @derive Jason.Encoder
  defstruct [
    :account_id,
    :closed_at,
    :reason
  ]

  @type t :: %__MODULE__{
    account_id: String.t(),
    closed_at: DateTime.t(),
    reason: String.t() | nil
  }
end
