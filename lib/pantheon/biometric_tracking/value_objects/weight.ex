defmodule Pantheon.BiometricTracking.ValueObjects.Weight do
  @moduledoc """
  Represents a body weight measurement in kilograms.

  Weight is a value object that encapsulates a body weight measurement
  with validation to ensure the value is within reasonable bounds for
  human body weight tracking in medical and fitness contexts.

  ## Validation Rules

  - Must be a positive number (> 0)
  - Must be ≤ 1000 kg (reasonable upper limit for medical equipment)
  - Cannot be infinity, negative infinity, or NaN
  - Automatically converts integers to floats for consistency
  - Supports precision for accurate medical measurements

  ## Examples

      # Create from integer
      iex> {:ok, weight} = Weight.new(70)
      iex> weight.kg
      70.0

      # Create from float with precision
      iex> {:ok, weight} = Weight.new(68.75)
      iex> weight.kg
      68.75

      # Invalid weights
      iex> Weight.new(-5)
      {:error, :invalid_weight}

      iex> Weight.new(0)
      {:error, :invalid_weight}

      iex> Weight.new(1500)
      {:error, :invalid_weight}
  """

  @type t :: %__MODULE__{kg: float()}

  defstruct [:kg]

  # Maximum reasonable weight for human tracking (1000 kg)
  # This accommodates medical equipment limits and extreme cases
  @max_weight 1000

  @doc """
  Creates a new Weight value object from a numeric value in kilograms.

  The input must be a positive number not exceeding the maximum weight limit.
  Integer values are automatically converted to floats for consistency and
  to support precise medical measurements.

  ## Parameters

    - `kg` - The weight value in kilograms (integer or float)

  ## Returns

    - `{:ok, %Weight{}}` - Success with the created weight
    - `{:error, :invalid_weight}` - If the value is invalid

  ## Examples

      iex> Weight.new(70)
      {:ok, %Weight{kg: 70.0}}

      iex> Weight.new(68.5)
      {:ok, %Weight{kg: 68.5}}

      iex> Weight.new(0)
      {:error, :invalid_weight}

      iex> Weight.new(-10)
      {:error, :invalid_weight}

      iex> Weight.new(1500)
      {:error, :invalid_weight}
  """
  @spec new(number()) :: {:ok, t()} | {:error, :invalid_weight}
  def new(kg) when is_number(kg) and kg > 0 and kg <= @max_weight do
    # Convert to float for consistency (multiply by 1.0 ensures float type)
    {:ok, %__MODULE__{kg: kg * 1.0}}
  end

  def new(_), do: {:error, :invalid_weight}
end
