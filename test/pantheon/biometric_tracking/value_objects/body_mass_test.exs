defmodule Pantheon.BiometricTracking.ValueObjects.BodyMassTest do
  use ExUnit.Case, async: true

  alias Pantheon.BiometricTracking.ValueObjects.BodyMass

  describe "new/1" do
    test "creates body mass from valid integer kilograms" do
      assert {:ok, %BodyMass{kg: 25.0}} = BodyMass.new(25)
    end

    test "creates body mass from valid float kilograms" do
      assert {:ok, %BodyMass{kg: 15.75}} = BodyMass.new(15.75)
    end

    test "accepts zero mass" do
      assert {:ok, %BodyMass{kg: mass}} = BodyMass.new(0)
      assert mass == 0.0
    end

    test "accepts very small masses" do
      assert {:ok, %BodyMass{kg: 0.01}} = BodyMass.new(0.01)
      assert {:ok, %BodyMass{kg: 0.1}} = BodyMass.new(0.1)
    end

    test "handles maximum reasonable mass" do
      assert {:ok, %BodyMass{kg: 500.0}} = BodyMass.new(500)
    end

    test "converts integer to float for consistency" do
      assert {:ok, %BodyMass{kg: kg}} = BodyMass.new(30)
      assert is_float(kg)
      assert kg == 30.0
    end

    test "preserves float precision" do
      assert {:ok, %BodyMass{kg: 18.125}} = BodyMass.new(18.125)
    end

    test "handles typical body mass component ranges" do
      # Fat mass ranges (for different body compositions)
      assert {:ok, %BodyMass{kg: 5.0}} = BodyMass.new(5)    # Low fat mass
      assert {:ok, %BodyMass{kg: 15.0}} = BodyMass.new(15)  # Average fat mass
      assert {:ok, %BodyMass{kg: 30.0}} = BodyMass.new(30)  # Higher fat mass

      # Lean mass ranges
      assert {:ok, %BodyMass{kg: 40.0}} = BodyMass.new(40)  # Smaller person lean mass
      assert {:ok, %BodyMass{kg: 60.0}} = BodyMass.new(60)  # Average lean mass
      assert {:ok, %BodyMass{kg: 80.0}} = BodyMass.new(80)  # Athletic lean mass

      # Muscle mass ranges
      assert {:ok, %BodyMass{kg: 20.0}} = BodyMass.new(20)  # Lower muscle mass
      assert {:ok, %BodyMass{kg: 35.0}} = BodyMass.new(35)  # Average muscle mass
      assert {:ok, %BodyMass{kg: 50.0}} = BodyMass.new(50)  # High muscle mass

      # Skeletal mass ranges (typically 2-4kg for adults)
      assert {:ok, %BodyMass{kg: 2.5}} = BodyMass.new(2.5)
      assert {:ok, %BodyMass{kg: 3.8}} = BodyMass.new(3.8)
    end

    test "accepts edge case masses" do
      # Very low masses for specialized measurements
      assert {:ok, %BodyMass{kg: 0.001}} = BodyMass.new(0.001)

      # Higher masses for large individuals
      assert {:ok, %BodyMass{kg: 200.0}} = BodyMass.new(200)
      assert {:ok, %BodyMass{kg: 400.0}} = BodyMass.new(400)
    end

    test "rejects negative mass" do
      assert {:error, :invalid_body_mass} = BodyMass.new(-1)
      assert {:error, :invalid_body_mass} = BodyMass.new(-10.5)
      assert {:error, :invalid_body_mass} = BodyMass.new(-0.1)
      assert {:error, :invalid_body_mass} = BodyMass.new(-0.001)
    end

    test "rejects mass above maximum limit" do
      assert {:error, :invalid_body_mass} = BodyMass.new(500.1)
      assert {:error, :invalid_body_mass} = BodyMass.new(600)
      assert {:error, :invalid_body_mass} = BodyMass.new(1000)
    end

    test "rejects non-numeric values" do
      assert {:error, :invalid_body_mass} = BodyMass.new("25")
      assert {:error, :invalid_body_mass} = BodyMass.new("15.5")
      assert {:error, :invalid_body_mass} = BodyMass.new(nil)
      assert {:error, :invalid_body_mass} = BodyMass.new(:invalid)
      assert {:error, :invalid_body_mass} = BodyMass.new(%{})
      assert {:error, :invalid_body_mass} = BodyMass.new([])
      assert {:error, :invalid_body_mass} = BodyMass.new("medium")
    end

    test "rejects special float values" do
      assert {:error, :invalid_body_mass} = BodyMass.new(:infinity)
      assert {:error, :invalid_body_mass} = BodyMass.new(:negative_infinity)
      assert {:error, :invalid_body_mass} = BodyMass.new(:nan)
    end
  end

  describe "equality and comparison" do
    test "body masses with same value are equal" do
      {:ok, mass1} = BodyMass.new(25.5)
      {:ok, mass2} = BodyMass.new(25.5)

      assert mass1 == mass2
    end

    test "body masses with different values are not equal" do
      {:ok, mass1} = BodyMass.new(25.5)
      {:ok, mass2} = BodyMass.new(26.0)

      assert mass1 != mass2
    end

    test "integer and float representations are equal" do
      {:ok, mass_int} = BodyMass.new(25)      # Integer input
      {:ok, mass_float} = BodyMass.new(25.0)  # Float input

      assert mass_int == mass_float
      assert mass_int.kg == mass_float.kg
    end
  end

  describe "boundary conditions" do
    test "handles edge case of exactly 0 kg" do
      assert {:ok, %BodyMass{kg: mass}} = BodyMass.new(0)
      assert mass == 0.0

      assert {:ok, %BodyMass{kg: mass}} = BodyMass.new(0.0)
      assert mass == 0.0
    end

    test "handles edge case of maximum mass" do
      assert {:ok, %BodyMass{kg: 500.0}} = BodyMass.new(500.0)
      assert {:ok, %BodyMass{kg: 500.0}} = BodyMass.new(500)
    end

    test "rejects mass just above maximum" do
      assert {:error, :invalid_body_mass} = BodyMass.new(500.01)
      assert {:error, :invalid_body_mass} = BodyMass.new(500.1)
    end

    test "rejects mass just below minimum" do
      assert {:error, :invalid_body_mass} = BodyMass.new(-0.01)
      assert {:error, :invalid_body_mass} = BodyMass.new(-0.001)
    end

    test "handles very small positive masses" do
      assert {:ok, %BodyMass{kg: 0.001}} = BodyMass.new(0.001)
      assert {:ok, %BodyMass{kg: 0.01}} = BodyMass.new(0.01)
    end

    test "handles masses very close to maximum" do
      assert {:ok, %BodyMass{kg: 499.99}} = BodyMass.new(499.99)
      assert {:ok, %BodyMass{kg: 499.9}} = BodyMass.new(499.9)
    end
  end

  describe "use cases for different mass types" do
    test "supports fat mass measurements" do
      # Typical fat mass ranges for different body types
      assert {:ok, %BodyMass{kg: 8.5}} = BodyMass.new(8.5)   # Athletic
      assert {:ok, %BodyMass{kg: 15.2}} = BodyMass.new(15.2) # Average
      assert {:ok, %BodyMass{kg: 25.0}} = BodyMass.new(25.0) # Higher fat
    end

    test "supports lean mass measurements" do
      # Typical lean mass ranges
      assert {:ok, %BodyMass{kg: 45.0}} = BodyMass.new(45.0) # Smaller individual
      assert {:ok, %BodyMass{kg: 65.0}} = BodyMass.new(65.0) # Average
      assert {:ok, %BodyMass{kg: 85.0}} = BodyMass.new(85.0) # Large/athletic
    end

    test "supports muscle mass measurements" do
      # Typical muscle mass ranges
      assert {:ok, %BodyMass{kg: 25.0}} = BodyMass.new(25.0) # Lower
      assert {:ok, %BodyMass{kg: 35.0}} = BodyMass.new(35.0) # Average
      assert {:ok, %BodyMass{kg: 45.0}} = BodyMass.new(45.0) # Athletic
    end

    test "supports skeletal mass measurements" do
      # Typical skeletal mass ranges (bone mass)
      assert {:ok, %BodyMass{kg: 2.2}} = BodyMass.new(2.2)   # Lower
      assert {:ok, %BodyMass{kg: 3.1}} = BodyMass.new(3.1)   # Average
      assert {:ok, %BodyMass{kg: 4.5}} = BodyMass.new(4.5)   # Higher
    end
  end
end
