defmodule FinancialAccounts.Domain.Transfer do
  @moduledoc """
  Transfer aggregate for the Financial Accounts bounded context.

  Manages transfers between accounts. A transfer creates two linked transactions:
  one withdrawal from the source account and one deposit to the destination account.

  Key business rules:
  - Cannot transfer to the same account
  - Both accounts must belong to the same user
  - Cross-currency transfers use exchange rates (with optional override)
  - Cancelled transfers void both linked transactions
  - Transfer amount is in source currency
  """

  alias FinancialAccounts.Commands.{
    CreateTransfer,
    CancelTransfer
  }

  alias FinancialAccounts.Events.{
    TransferCreated,
    TransferCancelled
  }

  defstruct [
    :transfer_id,
    :user_id,
    :from_account_id,
    :to_account_id,
    :amount,
    :source_currency,
    :target_currency,
    :exchange_rate,
    :transfer_date,
    :description,
    :notes,
    :from_transaction_id,
    :to_transaction_id,
    :is_cancelled,
    :created_at,
    :cancelled_at
  ]

  @type t :: %__MODULE__{
    transfer_id: String.t() | nil,
    user_id: String.t() | nil,
    from_account_id: String.t() | nil,
    to_account_id: String.t() | nil,
    amount: Decimal.t() | nil,
    source_currency: String.t() | nil,
    target_currency: String.t() | nil,
    exchange_rate: Decimal.t() | nil,
    transfer_date: Date.t() | nil,
    description: String.t() | nil,
    notes: String.t() | nil,
    from_transaction_id: String.t() | nil,
    to_transaction_id: String.t() | nil,
    is_cancelled: boolean(),
    created_at: DateTime.t() | nil,
    cancelled_at: DateTime.t() | nil
  }

  # Command Handlers

  @doc """
  Handles commands for the Transfer aggregate.
  """
  def execute(%__MODULE__{transfer_id: nil}, %CreateTransfer{} = command) do
    with :ok <- validate_different_accounts(command.from_account_id, command.to_account_id),
         :ok <- validate_amount(command.amount),
         :ok <- validate_date(command.transfer_date) do

      # Generate transaction IDs for linked transactions
      from_transaction_id = UUID.uuid4()
      to_transaction_id = UUID.uuid4()

      # For now, we'll assume same currency (cross-currency will need account lookup)
      # In practice, this would fetch account currencies and calculate exchange rate

      %TransferCreated{
        transfer_id: command.transfer_id,
        user_id: command.user_id,
        from_account_id: command.from_account_id,
        to_account_id: command.to_account_id,
        amount: command.amount,
        source_currency: "CAD",  # TODO: Get from account
        target_currency: "CAD",  # TODO: Get from account
        exchange_rate: command.exchange_rate_override,
        system_exchange_rate_id: nil,  # TODO: Fetch if cross-currency
        user_exchange_rate_id: nil,
        transfer_date: command.transfer_date,
        description: command.description || "Transfer",
        notes: command.notes,
        from_transaction_id: from_transaction_id,
        to_transaction_id: to_transaction_id,
        created_at: DateTime.utc_now()
      }
    end
  end

  def execute(%__MODULE__{transfer_id: id}, %CreateTransfer{}) when not is_nil(id) do
    {:error, :transfer_already_exists}
  end

  def execute(%__MODULE__{transfer_id: nil}, %CancelTransfer{}) do
    {:error, :transfer_not_found}
  end

  def execute(%__MODULE__{is_cancelled: true}, %CancelTransfer{}) do
    {:error, :transfer_already_cancelled}
  end

  def execute(%__MODULE__{}, %CancelTransfer{} = command) do
    %TransferCancelled{
      transfer_id: command.transfer_id,
      reason: command.reason,
      cancelled_at: DateTime.utc_now()
    }
  end

  # State Mutators (apply events to update aggregate state)

  @doc """
  Applies events to aggregate state.
  """
  def apply(%__MODULE__{}, %TransferCreated{} = event) do
    %__MODULE__{
      transfer_id: event.transfer_id,
      user_id: event.user_id,
      from_account_id: event.from_account_id,
      to_account_id: event.to_account_id,
      amount: event.amount,
      source_currency: event.source_currency,
      target_currency: event.target_currency,
      exchange_rate: event.exchange_rate,
      transfer_date: event.transfer_date,
      description: event.description,
      notes: event.notes,
      from_transaction_id: event.from_transaction_id,
      to_transaction_id: event.to_transaction_id,
      is_cancelled: false,
      created_at: event.created_at
    }
  end

  def apply(%__MODULE__{} = transfer, %TransferCancelled{} = event) do
    %{transfer |
      is_cancelled: true,
      cancelled_at: event.cancelled_at
    }
  end

  # Private validation functions

  defp validate_different_accounts(from_id, to_id) when from_id == to_id do
    {:error, :cannot_transfer_to_same_account}
  end
  defp validate_different_accounts(_from_id, _to_id), do: :ok

  defp validate_amount(%Decimal{} = amount) do
    cond do
      Decimal.eq?(amount, Decimal.new(0)) ->
        {:error, :amount_cannot_be_zero}
      Decimal.lt?(amount, Decimal.new(0)) ->
        {:error, :amount_must_be_positive}
      true ->
        :ok
    end
  end
  defp validate_amount(_), do: {:error, :invalid_amount}

  defp validate_date(%Date{} = _date), do: :ok
  defp validate_date(_), do: {:error, :invalid_date}
end
