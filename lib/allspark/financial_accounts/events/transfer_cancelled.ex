defmodule FinancialAccounts.Events.TransferCancelled do
  @moduledoc """
  Event emitted when a transfer is cancelled.

  Cancelling a transfer voids both linked transactions.
  """

  @derive Jason.Encoder
  defstruct [
    :transfer_id,
    :reason,
    :cancelled_at
  ]

  @type t :: %__MODULE__{
    transfer_id: String.t(),
    reason: String.t() | nil,
    cancelled_at: DateTime.t()
  }
end
