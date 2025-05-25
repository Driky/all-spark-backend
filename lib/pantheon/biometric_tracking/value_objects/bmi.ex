# lib/pantheon/biometric_tracking/value_objects/bmi.ex

defmodule Pantheon.BiometricTracking.ValueObjects.BMI do
  @moduledoc """
  Represents a Body Mass Index (BMI) calculation.

  BMI is a value object that encapsulates a Body Mass Index measurement,
  which is a person's weight in kilograms divided by the square of height
  in meters. BMI is widely used in healthcare to classify weight status
  and assess health risks related to body weight.

  ## Validation Rules

  - Must be a positive number (> 0)
  - Must be between 10 and 100 (reasonable medical range)
  - Cannot be infinity, negative infinity, or NaN
  - Automatically converts integers to floats for consistency
  - Supports high precision for medical calculations

  ## BMI Classifications (WHO Standards)

  - **Underweight:** BMI < 18.5
    - Severe thinness: < 16
    - Moderate thinness: 16-17
    - Mild thinness: 17-18.5

  - **Normal weight:** BMI 18.5-24.9

  - **Overweight:** BMI 25-29.9

  - **Obesity:** BMI ≥ 30
    - Class I (Moderate): 30-34.9
    - Class II (Severe): 35-39.9
    - Class III (Very severe): ≥ 40

  ## Calculation Formula

      BMI = weight (kg) / height (m)²

  ## Examples

      # Normal BMI
      iex> {:ok, bmi} = BMI.new(22.5)
      iex> bmi.value
      22.5

      # Overweight BMI
      iex> {:ok, bmi} = BMI.new(27)
      iex> bmi.value
      27.0

      # Invalid BMI values
      iex> BMI.new(0)
      {:error, :invalid_bmi}

      iex> BMI.new(-5)
      {:error, :invalid_bmi}

      iex> BMI.new(150)
      {:error, :invalid_bmi}
  """

  @type t :: %__MODULE__{value: float()}

  defstruct [:value]

  # Reasonable BMI range based on medical literature
  @min_bmi 10   # Extreme underweight (medical conditions)
  @max_bmi 100  # Extreme obesity (medical cases)

  @doc """
  Creates a new BMI value object from a numeric BMI value.

  The input must be a positive number within the reasonable medical range
  for BMI values. Integer values are automatically converted to floats
  for consistency and to support precise medical calculations.

  ## Parameters

    - `value` - The BMI value (integer or float, between #{@min_bmi} and #{@max_bmi})

  ## Returns

    - `{:ok, %BMI{}}` - Success with the created BMI
    - `{:error, :invalid_bmi}` - If the value is invalid

  ## Examples

      iex> BMI.new(22)
      {:ok, %BMI{value: 22.0}}

      iex> BMI.new(25.5)
      {:ok, %BMI{value: 25.5}}

      iex> BMI.new(18.5)
      {:ok, %BMI{value: 18.5}}

      iex> BMI.new(0)
      {:error, :invalid_bmi}

      iex> BMI.new(-1)
      {:error, :invalid_bmi}

      iex> BMI.new(150)
      {:error, :invalid_bmi}
  """
  @spec new(number()) :: {:ok, t()} | {:error, :invalid_bmi}
  def new(value) when is_number(value) and value >= @min_bmi and value <= @max_bmi do
    # Convert to float for consistency (multiply by 1.0 ensures float type)
    {:ok, %__MODULE__{value: value * 1.0}}
  end

  def new(_), do: {:error, :invalid_bmi}
end
