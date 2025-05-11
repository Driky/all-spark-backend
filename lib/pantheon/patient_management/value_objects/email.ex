defmodule Pantheon.PatientManagement.ValueObjects.Email do
  @moduledoc """
  Value object representing an email address.
  """
  @type t :: String.t()

  @email_regex ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/

  @doc """
  Validates that a given string is a valid email address.
  """
  @spec validate(String.t()) :: {:ok, t()} | {:error, :invalid_email}
  def validate(email) when is_binary(email) do
    if Regex.match?(@email_regex, email) do
      {:ok, email}
    else
      {:error, :invalid_email}
    end
  end
  def validate(_), do: {:error, :invalid_email}
end
