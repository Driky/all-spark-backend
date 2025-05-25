# lib/pantheon/biometric_tracking/value_objects/metabolic_age.ex

defmodule Pantheon.BiometricTracking.ValueObjects.MetabolicAge do
  @moduledoc """
  Represents a metabolic age measurement in years.

  MetabolicAge is a value object that encapsulates a person's metabolic age,
  which represents the age of a person based on their metabolic health and
  fitness level rather than their chronological age. This measurement is
  commonly provided by body composition analyzers and fitness assessments.

  ## Validation Rules

  - Must be a positive integer (> 0)
  - Must be between 10 and 150 years (reasonable human lifespan range)
  - Cannot be a float value (ages are whole years)
  - Cannot be infinity, negative infinity, or NaN
  - Stores as integer (no conversion to float)

  ## Metabolic Age Concept

  Metabolic age compares your basal metabolic rate (BMR) to the average BMR
  of people in different age groups. It provides insight into:

  - **Lower than chronological age:** Indicates good metabolic health and fitness
  - **Equal to chronological age:** Indicates average metabolic health for your age
  - **Higher than chronological age:** May indicate need for lifestyle improvements

  ## Factors Affecting Metabolic Age

  - Muscle mass (more muscle = lower metabolic age)
  - Body fat percentage (lower fat = lower metabolic age)
  - Physical activity level
  - Diet and nutrition
  - Genetics
  - Overall health status

  ## Examples

      # Young metabolic age (good fitness)
      iex> {:ok, age} = MetabolicAge.new(25)
      iex> age.years
      25

      # Average metabolic age
      iex> {:ok, age} = MetabolicAge.new(40)
      iex> age.years
      40

      # Higher metabolic age (may need lifestyle changes)
      iex> {:ok, age} = MetabolicAge.new(55)
      iex> age.years
      55

      # Invalid metabolic ages
      iex> MetabolicAge.new(0)
      {:error, :invalid_metabolic_age}

      iex> MetabolicAge.new(25.5)
      {:error, :invalid_metabolic_age}

      iex> MetabolicAge.new(200)
      {:error, :invalid_metabolic_age}
  """

  @type t :: %__MODULE__{years: integer()}

  defstruct [:years]

  # Reasonable age range for metabolic age calculations
  @min_age 10   # Minimum age for metabolic calculations
  @max_age 150  # Maximum reasonable human age

  @doc """
  Creates a new MetabolicAge value object from an integer age value.

  The input must be a positive integer within the reasonable human age range.
  Unlike other measurements, metabolic age is always represented as whole years,
  so float values are rejected.

  ## Parameters

    - `years` - The metabolic age in years (integer, between #{@min_age} and #{@max_age})

  ## Returns

    - `{:ok, %MetabolicAge{}}` - Success with the created metabolic age
    - `{:error, :invalid_metabolic_age}` - If the value is invalid

  ## Examples

      iex> MetabolicAge.new(25)
      {:ok, %MetabolicAge{years: 25}}

      iex> MetabolicAge.new(40)
      {:ok, %MetabolicAge{years: 40}}

      iex> MetabolicAge.new(0)
      {:error, :invalid_metabolic_age}

      iex> MetabolicAge.new(25.5)
      {:error, :invalid_metabolic_age}

      iex> MetabolicAge.new(200)
      {:error, :invalid_metabolic_age}
  """
  @spec new(integer()) :: {:ok, t()} | {:error, :invalid_metabolic_age}
  def new(years) when is_integer(years) and years >= @min_age and years <= @max_age do
    {:ok, %__MODULE__{years: years}}
  end

  def new(_), do: {:error, :invalid_metabolic_age}
end
