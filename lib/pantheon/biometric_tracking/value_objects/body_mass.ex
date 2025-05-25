defmodule Pantheon.BiometricTracking.ValueObjects.BodyMass do
  @moduledoc """
  Represents a body mass component measurement in kilograms.

  BodyMass is a value object that encapsulates measurements of various body
  mass components such as fat mass, lean mass, muscle mass, and skeletal mass.
  These measurements are typically obtained through body composition analysis
  using methods like DEXA scans, bioelectrical impedance, or hydrostatic weighing.

  ## Validation Rules

  - Must be a non-negative number (>= 0)
  - Must be ≤ 500 kg (reasonable upper limit for body components)
  - Cannot be infinity, negative infinity, or NaN
  - Automatically converts integers to floats for consistency
  - Supports high precision for medical and research applications

  ## Common Body Mass Components

  **Fat Mass:** The total weight of fat in the body
  - Essential fat: ~2-5% of body weight for men, ~10-13% for women
  - Storage fat: Additional fat beyond essential requirements

  **Lean Mass:** All body mass except fat (muscle, bone, organs, water)
  - Typically 70-85% of total body weight
  - Includes muscle mass, skeletal mass, and organ mass

  **Muscle Mass:** Skeletal muscle tissue weight
  - Typically 30-50% of total body weight
  - Varies significantly with fitness level and genetics

  **Skeletal Mass:** Bone mineral content weight
  - Typically 2-4 kg for adults
  - Important for assessing bone health and osteoporosis risk

  ## Examples

      # Fat mass measurement
      iex> {:ok, fat_mass} = BodyMass.new(15.2)
      iex> fat_mass.kg
      15.2

      # Lean mass measurement
      iex> {:ok, lean_mass} = BodyMass.new(58.5)
      iex> lean_mass.kg
      58.5

      # Zero mass (edge case)
      iex> {:ok, zero_mass} = BodyMass.new(0)
      iex> zero_mass.kg
      0.0

      # Invalid masses
      iex> BodyMass.new(-5)
      {:error, :invalid_body_mass}

      iex> BodyMass.new(600)
      {:error, :invalid_body_mass}
  """

  @type t :: %__MODULE__{kg: float()}

  defstruct [:kg]

  # Maximum reasonable mass for body components (500 kg)
  # This is lower than total body weight since these are components
  @max_mass 500

  @doc """
  Creates a new BodyMass value object from a numeric value in kilograms.

  The input must be a non-negative number not exceeding the maximum mass limit.
  Integer values are automatically converted to floats for consistency and
  to support precise medical measurements.

  ## Parameters

    - `kg` - The mass value in kilograms (integer or float, >= 0)

  ## Returns

    - `{:ok, %BodyMass{}}` - Success with the created body mass
    - `{:error, :invalid_body_mass}` - If the value is invalid

  ## Examples

      iex> BodyMass.new(25)
      {:ok, %BodyMass{kg: 25.0}}

      iex> BodyMass.new(15.75)
      {:ok, %BodyMass{kg: 15.75}}

      iex> BodyMass.new(0)
      {:ok, %BodyMass{kg: 0.0}}

      iex> BodyMass.new(-1)
      {:error, :invalid_body_mass}

      iex> BodyMass.new(600)
      {:error, :invalid_body_mass}
  """
  @spec new(number()) :: {:ok, t()} | {:error, :invalid_body_mass}
  def new(kg) when is_number(kg) and kg >= 0 and kg <= @max_mass do
    # Convert to float for consistency (multiply by 1.0 ensures float type)
    {:ok, %__MODULE__{kg: kg * 1.0}}
  end

  def new(_), do: {:error, :invalid_body_mass}
end
