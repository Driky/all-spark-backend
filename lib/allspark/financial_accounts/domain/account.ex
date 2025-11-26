defmodule FinancialAccounts.Domain.Account do
  @moduledoc """
  Account aggregate for the Financial Accounts bounded context.

  Manages the lifecycle of a financial account including creation, opening balance,
  and basic account properties. The account serves as the root aggregate for all
  transactions belonging to it.

  Key business rules:
  - Account type and base currency are immutable once set
  - Opening balance date establishes minimum transaction date
  - Closed accounts cannot be reopened (soft delete only)
  - Each account belongs to a single user
  """

  alias FinancialAccounts.Commands.{
    OpenAccount,
    SetOpeningBalance,
    RenameAccount,
    CloseAccount
  }

  alias FinancialAccounts.Events.{
    AccountOpened,
    OpeningBalanceSet,
    AccountRenamed,
    AccountClosed
  }

  defstruct [
    :account_id,
    :user_id,
    :name,
    :account_type,
    :base_currency,
    :opening_balance,
    :opening_balance_date,
    :status,  # :open | :closed
    :opened_at,
    :closed_at
  ]

  @type t :: %__MODULE__{
    account_id: String.t() | nil,
    user_id: String.t() | nil,
    name: String.t() | nil,
    account_type: atom() | nil,
    base_currency: String.t() | nil,
    opening_balance: Decimal.t() | nil,
    opening_balance_date: Date.t() | nil,
    status: :open | :closed,
    opened_at: DateTime.t() | nil,
    closed_at: DateTime.t() | nil
  }

  # Valid account types
  @valid_account_types [
    :checking,
    :savings,
    :credit_card,
    :investment_taxable,
    :investment_rrsp,
    :investment_tfsa,
    :investment_rrif,
    :investment_fhsa,
    :loan,
    :mortgage,
    :cash,
    :other
  ]

  # Command Handlers

  @doc """
  Handles commands for the Account aggregate.
  """
  def execute(%__MODULE__{account_id: nil}, %OpenAccount{} = command) do
    with :ok <- validate_account_type(command.account_type),
         :ok <- validate_currency(command.base_currency),
         :ok <- validate_name(command.name) do
      %AccountOpened{
        account_id: command.account_id,
        user_id: command.user_id,
        name: command.name,
        account_type: command.account_type,
        base_currency: command.base_currency,
        opened_at: DateTime.utc_now()
      }
    end
  end

  def execute(%__MODULE__{account_id: id}, %OpenAccount{}) when not is_nil(id) do
    {:error, :account_already_exists}
  end

  def execute(%__MODULE__{account_id: nil}, %SetOpeningBalance{}) do
    {:error, :account_not_found}
  end

  def execute(%__MODULE__{status: :closed}, %SetOpeningBalance{}) do
    {:error, :account_closed}
  end

  def execute(%__MODULE__{}, %SetOpeningBalance{} = command) do
    with :ok <- validate_balance(command.balance),
         :ok <- validate_date(command.as_of_date) do
      %OpeningBalanceSet{
        account_id: command.account_id,
        balance: command.balance,
        as_of_date: command.as_of_date,
        set_at: DateTime.utc_now()
      }
    end
  end

  def execute(%__MODULE__{account_id: nil}, %RenameAccount{}) do
    {:error, :account_not_found}
  end

  def execute(%__MODULE__{status: :closed}, %RenameAccount{}) do
    {:error, :account_closed}
  end

  def execute(%__MODULE__{name: current_name}, %RenameAccount{new_name: new_name})
      when current_name == new_name do
    {:error, :name_unchanged}
  end

  def execute(%__MODULE__{}, %RenameAccount{} = command) do
    with :ok <- validate_name(command.new_name) do
      %AccountRenamed{
        account_id: command.account_id,
        new_name: command.new_name,
        renamed_at: DateTime.utc_now()
      }
    end
  end

  def execute(%__MODULE__{account_id: nil}, %CloseAccount{}) do
    {:error, :account_not_found}
  end

  def execute(%__MODULE__{status: :closed}, %CloseAccount{}) do
    {:error, :account_already_closed}
  end

  def execute(%__MODULE__{}, %CloseAccount{} = command) do
    %AccountClosed{
      account_id: command.account_id,
      closed_at: DateTime.utc_now(),
      reason: command.reason
    }
  end

  # State Mutators (apply events to update aggregate state)

  @doc """
  Applies events to aggregate state.
  """
  def apply(%__MODULE__{}, %AccountOpened{} = event) do
    %__MODULE__{
      account_id: event.account_id,
      user_id: event.user_id,
      name: event.name,
      account_type: event.account_type,
      base_currency: event.base_currency,
      status: :open,
      opened_at: event.opened_at
    }
  end

  def apply(%__MODULE__{} = account, %OpeningBalanceSet{} = event) do
    %{account |
      opening_balance: event.balance,
      opening_balance_date: event.as_of_date
    }
  end

  def apply(%__MODULE__{} = account, %AccountRenamed{} = event) do
    %{account | name: event.new_name}
  end

  def apply(%__MODULE__{} = account, %AccountClosed{} = event) do
    %{account |
      status: :closed,
      closed_at: event.closed_at
    }
  end

  # Private validation functions

  defp validate_account_type(type) when type in @valid_account_types, do: :ok
  defp validate_account_type(_), do: {:error, :invalid_account_type}

  defp validate_currency(currency) when is_binary(currency) and byte_size(currency) >= 3 do
    # Basic validation - should be 3+ character currency code
    :ok
  end
  defp validate_currency(_), do: {:error, :invalid_currency}

  defp validate_name(name) when is_binary(name) and byte_size(name) > 0 and byte_size(name) <= 100 do
    :ok
  end
  defp validate_name(_), do: {:error, :invalid_name}

  defp validate_balance(%Decimal{} = _balance), do: :ok
  defp validate_balance(_), do: {:error, :invalid_balance}

  defp validate_date(%Date{} = _date), do: :ok
  defp validate_date(_), do: {:error, :invalid_date}
end
