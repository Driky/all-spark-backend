defmodule Pantheon.BiometricTracking.ValueObjects.WeightTest do
  use ExUnit.Case, async: true

  alias Pantheon.BiometricTracking.ValueObjects.Weight

  describe "new/1" do
    test "creates weight from valid integer kilograms" do
      assert {:ok, %Weight{kg: 70.0}} = Weight.new(70)
    end

    test "creates weight from valid float kilograms" do
      assert {:ok, %Weight{kg: 70.5}} = Weight.new(70.5)
    end

    test "handles minimum valid weight" do
      assert {:ok, %Weight{kg: 0.1}} = Weight.new(0.1)
    end

    test "handles maximum reasonable weight" do
      assert {:ok, %Weight{kg: 1000.0}} = Weight.new(1000)
    end

    test "converts integer to float for consistency" do
      assert {:ok, %Weight{kg: kg}} = Weight.new(75)
      assert is_float(kg)
      assert kg == 75.0
    end

    test "preserves float precision" do
      assert {:ok, %Weight{kg: 68.75}} = Weight.new(68.75)
    end

    test "handles typical human weight ranges" do
      # Newborn weight
      assert {:ok, %Weight{kg: 3.5}} = Weight.new(3.5)

      # Child weight
      assert {:ok, %Weight{kg: 25.0}} = Weight.new(25)

      # Adult weight ranges
      assert {:ok, %Weight{kg: 50.0}} = Weight.new(50)
      assert {:ok, %Weight{kg: 120.0}} = Weight.new(120)

      # Athletic/bodybuilder ranges
      assert {:ok, %Weight{kg: 150.0}} = Weight.new(150)
    end

    test "rejects zero weight" do
      assert {:error, :invalid_weight} = Weight.new(0)
      assert {:error, :invalid_weight} = Weight.new(0.0)
    end

    test "rejects negative weight" do
      assert {:error, :invalid_weight} = Weight.new(-1)
      assert {:error, :invalid_weight} = Weight.new(-10.5)
      assert {:error, :invalid_weight} = Weight.new(-0.1)
    end

    test "rejects weight above maximum limit" do
      assert {:error, :invalid_weight} = Weight.new(1000.1)
      assert {:error, :invalid_weight} = Weight.new(1500)
      assert {:error, :invalid_weight} = Weight.new(9999)
    end

    test "rejects non-numeric values" do
      assert {:error, :invalid_weight} = Weight.new("70")
      assert {:error, :invalid_weight} = Weight.new("70.5")
      assert {:error, :invalid_weight} = Weight.new(nil)
      assert {:error, :invalid_weight} = Weight.new(:invalid)
      assert {:error, :invalid_weight} = Weight.new(%{})
      assert {:error, :invalid_weight} = Weight.new([])
    end

    test "rejects special float values" do
      assert {:error, :invalid_weight} = Weight.new(:infinity)
      assert {:error, :invalid_weight} = Weight.new(:negative_infinity)
      assert {:error, :invalid_weight} = Weight.new(:nan)
    end
  end

  describe "equality and comparison" do
    test "weights with same value are equal" do
      {:ok, weight1} = Weight.new(70.5)
      {:ok, weight2} = Weight.new(70.5)

      assert weight1 == weight2
    end

    test "weights with different values are not equal" do
      {:ok, weight1} = Weight.new(70.5)
      {:ok, weight2} = Weight.new(71.0)

      assert weight1 != weight2
    end

    test "integer and float representations are equal" do
      {:ok, weight_int} = Weight.new(70)    # Integer input
      {:ok, weight_float} = Weight.new(70.0)  # Float input

      assert weight_int == weight_float
      assert weight_int.kg == weight_float.kg
    end
  end

  describe "boundary conditions" do
    test "handles smallest positive weight" do
      assert {:ok, %Weight{kg: 0.01}} = Weight.new(0.01)
    end

    test "handles weight at maximum boundary" do
      assert {:ok, %Weight{kg: 1000.0}} = Weight.new(1000.0)
    end

    test "rejects weight just above maximum" do
      assert {:error, :invalid_weight} = Weight.new(1000.01)
    end

    test "rejects weight just below minimum" do
      assert {:error, :invalid_weight} = Weight.new(-0.01)
    end
  end
end
