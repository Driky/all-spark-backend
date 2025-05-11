defmodule Pantheon.PatientManagement.ValueObjects.PatientId do
  @moduledoc """
  Value object representing a unique patient identifier.
  """
  @type t :: String.t()

  @doc """
  Generates a new unique patient ID.
  """
  @spec generate() :: t()
  def generate do
    Ecto.UUID.generate()
  end

  @doc """
  Validates that a given string is a valid patient ID.
  """
  @spec validate(String.t()) :: {:ok, t()} | {:error, :invalid_patient_id}
  def validate(id) when is_binary(id) do
    case Ecto.UUID.cast(id) do
      {:ok, _} -> {:ok, id}
      :error -> {:error, :invalid_patient_id}
    end
  end
  def validate(_), do: {:error, :invalid_patient_id}
end
