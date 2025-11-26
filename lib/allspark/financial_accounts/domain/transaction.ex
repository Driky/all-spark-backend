defmodule FinancialAccounts.Domain.Transaction do
  @moduledoc """
  Transaction aggregate for the Financial Accounts bounded context.

  Manages individual financial transactions within an account. Each transaction
  records a financial activity (income, expense, transfer) and maintains its
  own lifecycle through status changes.

  Key business rules:
  - Transactions must be dated on or after account's opening balance date
  - Reconciled transactions cannot be edited without unreconciling first
  - Status workflow: pending → cleared → reconciled (can go backwards)
  - Voided transactions are excluded from balance calculations
  - Deleted transactions trigger balance recalculation
  """

  alias FinancialAccounts.Commands.{
    RecordTransaction,
    UpdateTransaction,
    ChangeTransactionStatus,
    VoidTransaction,
    DeleteTransaction
  }

  alias FinancialAccounts.Events.{
    TransactionRecorded,
    TransactionUpdated,
    TransactionStatusChanged,
    TransactionVoided,
    TransactionDeleted
  }

  defstruct [
    :transaction_id,
    :account_id,
    :user_id,
    :amount,
    :currency,
    :transaction_date,
    :description,
    :notes,
    :category_id,
    :payee,
    :status,
    :receipt_path,
    :is_voided,
    :recorded_at,
    :voided_at
  ]

  @type t :: %__MODULE__{
    transaction_id: String.t() | nil,
    account_id: String.t() | nil,
    user_id: String.t() | nil,
    amount: Decimal.t() | nil,
    currency: String.t() | nil,
    transaction_date: Date.t() | nil,
    description: String.t() | nil,
    notes: String.t() | nil,
    category_id: String.t() | nil,
    payee: String.t() | nil,
    status: atom() | nil,  # :pending | :cleared | :reconciled
    receipt_path: String.t() | nil,
    is_voided: boolean(),
    recorded_at: DateTime.t() | nil,
    voided_at: DateTime.t() | nil
  }

  # Valid transaction statuses
  @valid_statuses [:pending, :cleared, :reconciled]

  # Command Handlers

  @doc """
  Handles commands for the Transaction aggregate.
  """
  def execute(%__MODULE__{transaction_id: nil}, %RecordTransaction{} = command) do
    with :ok <- validate_amount(command.amount),
         :ok <- validate_currency(command.currency),
         :ok <- validate_date(command.transaction_date),
         :ok <- validate_description(command.description),
         :ok <- validate_status(command.status) do
      %TransactionRecorded{
        transaction_id: command.transaction_id,
        account_id: command.account_id,
        user_id: command.user_id,
        amount: command.amount,
        currency: command.currency,
        transaction_date: command.transaction_date,
        description: command.description,
        notes: command.notes,
        category_id: command.category_id,
        payee: command.payee,
        status: command.status || :pending,
        receipt_path: command.receipt_path,
        recorded_at: DateTime.utc_now()
      }
    end
  end

  def execute(%__MODULE__{transaction_id: id}, %RecordTransaction{}) when not is_nil(id) do
    {:error, :transaction_already_exists}
  end

  def execute(%__MODULE__{transaction_id: nil}, %UpdateTransaction{}) do
    {:error, :transaction_not_found}
  end

  def execute(%__MODULE__{is_voided: true}, %UpdateTransaction{}) do
    {:error, :transaction_voided}
  end

  def execute(%__MODULE__{status: :reconciled}, %UpdateTransaction{}) do
    {:error, :transaction_reconciled}
  end

  def execute(%__MODULE__{}, %UpdateTransaction{} = command) do
    updates = build_updates(command)

    if map_size(updates) == 0 do
      {:error, :no_changes}
    else
      with :ok <- validate_update_fields(updates) do
        %TransactionUpdated{
          transaction_id: command.transaction_id,
          amount: Map.get(updates, :amount),
          transaction_date: Map.get(updates, :transaction_date),
          description: Map.get(updates, :description),
          notes: Map.get(updates, :notes),
          category_id: Map.get(updates, :category_id),
          payee: Map.get(updates, :payee),
          receipt_path: Map.get(updates, :receipt_path),
          updated_at: DateTime.utc_now()
        }
      end
    end
  end

  def execute(%__MODULE__{transaction_id: nil}, %ChangeTransactionStatus{}) do
    {:error, :transaction_not_found}
  end

  def execute(%__MODULE__{is_voided: true}, %ChangeTransactionStatus{}) do
    {:error, :transaction_voided}
  end

  def execute(%__MODULE__{status: current_status}, %ChangeTransactionStatus{new_status: new_status})
      when current_status == new_status do
    {:error, :status_unchanged}
  end

  def execute(%__MODULE__{}, %ChangeTransactionStatus{} = command) do
    with :ok <- validate_status(command.new_status) do
      %TransactionStatusChanged{
        transaction_id: command.transaction_id,
        new_status: command.new_status,
        changed_at: DateTime.utc_now()
      }
    end
  end

  def execute(%__MODULE__{transaction_id: nil}, %VoidTransaction{}) do
    {:error, :transaction_not_found}
  end

  def execute(%__MODULE__{is_voided: true}, %VoidTransaction{}) do
    {:error, :transaction_already_voided}
  end

  def execute(%__MODULE__{}, %VoidTransaction{} = command) do
    %TransactionVoided{
      transaction_id: command.transaction_id,
      reason: command.reason,
      voided_at: DateTime.utc_now()
    }
  end

  def execute(%__MODULE__{transaction_id: nil}, %DeleteTransaction{}) do
    {:error, :transaction_not_found}
  end

  def execute(%__MODULE__{}, %DeleteTransaction{} = command) do
    %TransactionDeleted{
      transaction_id: command.transaction_id,
      account_id: command.account_id,
      deleted_at: DateTime.utc_now()
    }
  end

  # State Mutators (apply events to update aggregate state)

  @doc """
  Applies events to aggregate state.
  """
  def apply(%__MODULE__{}, %TransactionRecorded{} = event) do
    %__MODULE__{
      transaction_id: event.transaction_id,
      account_id: event.account_id,
      user_id: event.user_id,
      amount: event.amount,
      currency: event.currency,
      transaction_date: event.transaction_date,
      description: event.description,
      notes: event.notes,
      category_id: event.category_id,
      payee: event.payee,
      status: event.status,
      receipt_path: event.receipt_path,
      is_voided: false,
      recorded_at: event.recorded_at
    }
  end

  def apply(%__MODULE__{} = transaction, %TransactionUpdated{} = event) do
    transaction
    |> maybe_update(:amount, event.amount)
    |> maybe_update(:transaction_date, event.transaction_date)
    |> maybe_update(:description, event.description)
    |> maybe_update(:notes, event.notes)
    |> maybe_update(:category_id, event.category_id)
    |> maybe_update(:payee, event.payee)
    |> maybe_update(:receipt_path, event.receipt_path)
  end

  def apply(%__MODULE__{} = transaction, %TransactionStatusChanged{} = event) do
    %{transaction | status: event.new_status}
  end

  def apply(%__MODULE__{} = transaction, %TransactionVoided{} = event) do
    %{transaction |
      is_voided: true,
      voided_at: event.voided_at
    }
  end

  def apply(%__MODULE__{} = transaction, %TransactionDeleted{}) do
    transaction  # Keep state for projector to handle cleanup
  end

  # Private helper functions

  defp build_updates(command) do
    []
    |> maybe_add_update(:amount, command.amount)
    |> maybe_add_update(:transaction_date, command.transaction_date)
    |> maybe_add_update(:description, command.description)
    |> maybe_add_update(:notes, command.notes)
    |> maybe_add_update(:category_id, command.category_id)
    |> maybe_add_update(:payee, command.payee)
    |> maybe_add_update(:receipt_path, command.receipt_path)
    |> Enum.into(%{})
  end

  defp maybe_add_update(list, _key, nil), do: list
  defp maybe_add_update(list, key, value), do: [{key, value} | list]

  defp maybe_update(struct, _field, nil), do: struct
  defp maybe_update(struct, field, value), do: Map.put(struct, field, value)

  defp validate_update_fields(updates) do
    with :ok <- maybe_validate(:amount, Map.get(updates, :amount), &validate_amount/1),
         :ok <- maybe_validate(:transaction_date, Map.get(updates, :transaction_date), &validate_date/1),
         :ok <- maybe_validate(:description, Map.get(updates, :description), &validate_description/1) do
      :ok
    end
  end

  defp maybe_validate(_field, nil, _validator), do: :ok
  defp maybe_validate(_field, value, validator), do: validator.(value)

  # Validation functions

  defp validate_amount(%Decimal{} = amount) do
    if Decimal.eq?(amount, Decimal.new(0)) do
      {:error, :amount_cannot_be_zero}
    else
      :ok
    end
  end
  defp validate_amount(_), do: {:error, :invalid_amount}

  defp validate_currency(currency) when is_binary(currency) and byte_size(currency) >= 3 do
    :ok
  end
  defp validate_currency(_), do: {:error, :invalid_currency}

  defp validate_date(%Date{} = _date), do: :ok
  defp validate_date(_), do: {:error, :invalid_date}

  defp validate_description(desc) when is_binary(desc) and byte_size(desc) > 0 and byte_size(desc) <= 500 do
    :ok
  end
  defp validate_description(_), do: {:error, :invalid_description}

  defp validate_status(status) when status in @valid_statuses, do: :ok
  defp validate_status(_), do: {:error, :invalid_status}
end
