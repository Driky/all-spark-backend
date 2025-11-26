defmodule FinancialAccounts.Router do
  @moduledoc """
  Command router for the Financial Accounts bounded context.

  Routes commands to their respective aggregates and handles command dispatch.
  """

  use Commanded.Commands.Router

  alias FinancialAccounts.Domain.{Account, Transaction, Transfer}

  alias FinancialAccounts.Commands.{
    OpenAccount,
    SetOpeningBalance,
    RenameAccount,
    CloseAccount,
    RecordTransaction,
    UpdateTransaction,
    ChangeTransactionStatus,
    VoidTransaction,
    DeleteTransaction,
    CreateTransfer,
    CancelTransfer
  }

  # Account commands
  identify Account, by: :account_id, prefix: "account-"

  dispatch [OpenAccount, SetOpeningBalance, RenameAccount, CloseAccount],
    to: Account

  # Transaction commands
  identify Transaction, by: :transaction_id, prefix: "transaction-"

  dispatch [RecordTransaction, UpdateTransaction, ChangeTransactionStatus, VoidTransaction, DeleteTransaction],
    to: Transaction

  # Transfer commands
  identify Transfer, by: :transfer_id, prefix: "transfer-"

  dispatch [CreateTransfer, CancelTransfer],
    to: Transfer
end
