defmodule FinancialAccounts.Commands.CancelTransfer do
  @moduledoc """
  Command to cancel a transfer.

  This voids both linked transactions in the source and destination accounts.
  """

  defstruct [
    :transfer_id,
    :reason
  ]

  @type t :: %__MODULE__{
    transfer_id: String.t(),
    reason: String.t() | nil
  }
end
