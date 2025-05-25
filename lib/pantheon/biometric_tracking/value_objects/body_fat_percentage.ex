defmodule Pantheon.BiometricTracking.ValueObjects.BodyFatPercentage do
  @moduledoc """
  Represents a body fat percentage measurement.

  BodyFatPercentage is a value object that encapsulates a body fat percentage
  with validation to ensure the value is within the valid range of 0-100%.
  This measurement is commonly used in fitness and medical contexts to assess
  body composition and health status.

  ## Validation Rules

  - Must be a number between 0 and 100 (inclusive)
  - Cannot be negative
  - Cannot exceed 100%
  - Cannot be infinity, negative infinity, or NaN
  - Automatically converts integers to floats for consistency
  - Supports high precision for medical and research applications

  ## Body Fat Percentage Ranges (for reference)

  **Men:**
  - Essential fat: 2-5%
  - Athletic: 6-13%
  - Fitness: 14-17%
  - Average: 18-24%
  - Above average: 25%+

  **Women:**
  - Essential fat: 10-13%
  - Athletic: 14-20%
  - Fitness: 21-24%
  - Average: 25-31%
  - Above average: 32%+

  ## Examples

      # Create from integer
      iex> {:ok, bf} = BodyFatPercentage.new(15)
      iex> bf.percentage
      15.0

      # Create from float with precision
      iex> {:ok, bf} = BodyFatPercentage.new(12.75)
      iex> bf.percentage
      12.75

      # Boundary values
      iex> BodyFatPercentage.new(0)
      {:ok, %BodyFatPercentage{percentage: 0.0}}

      iex> BodyFatPercentage.new(100)
      {:ok, %BodyFatPercentage{percentage: 100.0}}

      # Invalid percentages
      iex> BodyFatPercentage.new(-5)
      {:error, :invalid_body_fat_percentage}

      iex> BodyFatPercentage.new(105)
      {:error, :invalid_body_fat_percentage}
  """

  @type t :: %__MODULE__{percentage: float()}

  defstruct [:percentage]

  @doc """
  Creates a new BodyFatPercentage value object from a numeric percentage value.

  The input must be a number between 0 and 100 (inclusive).
  Integer values are automatically converted to floats for consistency and
  to support precise medical and fitness measurements.

  ## Parameters

    - `percentage` - The body fat percentage value (0-100, integer or float)

  ## Returns

    - `{:ok, %BodyFatPercentage{}}` - Success with the created body fat percentage
    - `{:error, :invalid_body_fat_percentage}` - If the value is invalid

  ## Examples

      iex> BodyFatPercentage.new(15)
      {:ok, %BodyFatPercentage{percentage: 15.0}}

      iex> BodyFatPercentage.new(12.5)
      {:ok, %BodyFatPercentage{percentage: 12.5}}

      iex> BodyFatPercentage.new(0)
      {:ok, %BodyFatPercentage{percentage: 0.0}}

      iex> BodyFatPercentage.new(100)
      {:ok, %BodyFatPercentage{percentage: 100.0}}

      iex> BodyFatPercentage.new(-1)
      {:error, :invalid_body_fat_percentage}

      iex> BodyFatPercentage.new(101)
      {:error, :invalid_body_fat_percentage}
  """
  @spec new(number()) :: {:ok, t()} | {:error, :invalid_body_fat_percentage}
  def new(percentage) when is_number(percentage) and percentage >= 0 and percentage <= 100 do
    # Convert to float for consistency (multiply by 1.0 ensures float type)
    {:ok, %__MODULE__{percentage: percentage * 1.0}}
  end

  def new(_), do: {:error, :invalid_body_fat_percentage}
end
