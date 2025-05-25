# test/pantheon/biometric_tracking/value_objects/bmi_test.exs

defmodule Pantheon.BiometricTracking.ValueObjects.BMITest do
  use ExUnit.Case, async: true

  alias Pantheon.BiometricTracking.ValueObjects.BMI

  describe "new/1" do
    test "creates BMI from valid integer" do
      assert {:ok, %BMI{value: 22.0}} = BMI.new(22)
    end

    test "creates BMI from valid float" do
      assert {:ok, %BMI{value: 22.5}} = BMI.new(22.5)
    end

    test "handles minimum reasonable BMI" do
      assert {:ok, %BMI{value: 10.0}} = BMI.new(10)
    end

    test "handles maximum reasonable BMI" do
      assert {:ok, %BMI{value: 100.0}} = BMI.new(100)
    end

    test "converts integer to float for consistency" do
      assert {:ok, %BMI{value: bmi}} = BMI.new(25)
      assert is_float(bmi)
      assert bmi == 25.0
    end

    test "preserves float precision" do
      assert {:ok, %BMI{value: 23.75}} = BMI.new(23.75)
    end

    test "handles typical BMI ranges" do
      # Underweight (BMI < 18.5)
      assert {:ok, %BMI{value: 15.0}} = BMI.new(15)
      assert {:ok, %BMI{value: 17.5}} = BMI.new(17.5)
      assert {:ok, %BMI{value: 18.4}} = BMI.new(18.4)

      # Normal weight (BMI 18.5-24.9)
      assert {:ok, %BMI{value: 18.5}} = BMI.new(18.5)
      assert {:ok, %BMI{value: 21.0}} = BMI.new(21)
      assert {:ok, %BMI{value: 24.9}} = BMI.new(24.9)

      # Overweight (BMI 25-29.9)
      assert {:ok, %BMI{value: 25.0}} = BMI.new(25)
      assert {:ok, %BMI{value: 27.5}} = BMI.new(27.5)
      assert {:ok, %BMI{value: 29.9}} = BMI.new(29.9)

      # Obese Class I (BMI 30-34.9)
      assert {:ok, %BMI{value: 30.0}} = BMI.new(30)
      assert {:ok, %BMI{value: 32.5}} = BMI.new(32.5)
      assert {:ok, %BMI{value: 34.9}} = BMI.new(34.9)

      # Obese Class II (BMI 35-39.9)
      assert {:ok, %BMI{value: 35.0}} = BMI.new(35)
      assert {:ok, %BMI{value: 37.5}} = BMI.new(37.5)
      assert {:ok, %BMI{value: 39.9}} = BMI.new(39.9)

      # Obese Class III (BMI >= 40)
      assert {:ok, %BMI{value: 40.0}} = BMI.new(40)
      assert {:ok, %BMI{value: 45.0}} = BMI.new(45)
      assert {:ok, %BMI{value: 50.0}} = BMI.new(50)
    end

    test "handles extreme but medically possible BMI values" do
      # Very low BMI (severe underweight, medical conditions)
      assert {:ok, %BMI{value: 10.5}} = BMI.new(10.5)
      assert {:ok, %BMI{value: 12.0}} = BMI.new(12)

      # Very high BMI (severe obesity, medical cases)
      assert {:ok, %BMI{value: 60.0}} = BMI.new(60)
      assert {:ok, %BMI{value: 80.0}} = BMI.new(80)
    end

    test "rejects zero and negative BMI" do
      assert {:error, :invalid_bmi} = BMI.new(0)
      assert {:error, :invalid_bmi} = BMI.new(-1)
      assert {:error, :invalid_bmi} = BMI.new(-5.5)
      assert {:error, :invalid_bmi} = BMI.new(-0.1)
    end

    test "rejects BMI above maximum limit" do
      assert {:error, :invalid_bmi} = BMI.new(100.1)
      assert {:error, :invalid_bmi} = BMI.new(150)
      assert {:error, :invalid_bmi} = BMI.new(200)
    end

    test "rejects BMI below minimum limit" do
      assert {:error, :invalid_bmi} = BMI.new(9.9)
      assert {:error, :invalid_bmi} = BMI.new(5)
      assert {:error, :invalid_bmi} = BMI.new(1)
    end

    test "rejects non-numeric values" do
      assert {:error, :invalid_bmi} = BMI.new("22")
      assert {:error, :invalid_bmi} = BMI.new("22.5")
      assert {:error, :invalid_bmi} = BMI.new(nil)
      assert {:error, :invalid_bmi} = BMI.new(:invalid)
      assert {:error, :invalid_bmi} = BMI.new(%{})
      assert {:error, :invalid_bmi} = BMI.new([])
      assert {:error, :invalid_bmi} = BMI.new("normal")
    end

    test "rejects special float values" do
      assert {:error, :invalid_bmi} = BMI.new(:infinity)
      assert {:error, :invalid_bmi} = BMI.new(:negative_infinity)
      assert {:error, :invalid_bmi} = BMI.new(:nan)
    end
  end

  describe "equality and comparison" do
    test "BMI values with same value are equal" do
      {:ok, bmi1} = BMI.new(22.5)
      {:ok, bmi2} = BMI.new(22.5)

      assert bmi1 == bmi2
    end

    test "BMI values with different values are not equal" do
      {:ok, bmi1} = BMI.new(22.5)
      {:ok, bmi2} = BMI.new(23.0)

      assert bmi1 != bmi2
    end

    test "integer and float representations are equal" do
      {:ok, bmi_int} = BMI.new(25)      # Integer input
      {:ok, bmi_float} = BMI.new(25.0)  # Float input

      assert bmi_int == bmi_float
      assert bmi_int.value == bmi_float.value
    end
  end

  describe "boundary conditions" do
    test "handles edge case of minimum BMI" do
      assert {:ok, %BMI{value: 10.0}} = BMI.new(10.0)
      assert {:ok, %BMI{value: 10.0}} = BMI.new(10)
    end

    test "handles edge case of maximum BMI" do
      assert {:ok, %BMI{value: 100.0}} = BMI.new(100.0)
      assert {:ok, %BMI{value: 100.0}} = BMI.new(100)
    end

    test "rejects BMI just above maximum" do
      assert {:error, :invalid_bmi} = BMI.new(100.01)
      assert {:error, :invalid_bmi} = BMI.new(100.1)
    end

    test "rejects BMI just below minimum" do
      assert {:error, :invalid_bmi} = BMI.new(9.99)
      assert {:error, :invalid_bmi} = BMI.new(9.9)
    end

    test "handles BMI values very close to boundaries" do
      assert {:ok, %BMI{value: 10.01}} = BMI.new(10.01)
      assert {:ok, %BMI{value: 99.99}} = BMI.new(99.99)
    end
  end

  describe "BMI classification ranges" do
    test "supports underweight range" do
      assert {:ok, %BMI{value: 16.0}} = BMI.new(16)   # Severe underweight
      assert {:ok, %BMI{value: 17.0}} = BMI.new(17)   # Moderate underweight
      assert {:ok, %BMI{value: 18.0}} = BMI.new(18)   # Mild underweight
    end

    test "supports normal weight range" do
      assert {:ok, %BMI{value: 19.0}} = BMI.new(19)
      assert {:ok, %BMI{value: 21.5}} = BMI.new(21.5)
      assert {:ok, %BMI{value: 24.0}} = BMI.new(24)
    end

    test "supports overweight range" do
      assert {:ok, %BMI{value: 25.5}} = BMI.new(25.5)
      assert {:ok, %BMI{value: 27.0}} = BMI.new(27)
      assert {:ok, %BMI{value: 29.0}} = BMI.new(29)
    end

    test "supports obesity ranges" do
      assert {:ok, %BMI{value: 31.0}} = BMI.new(31)   # Class I
      assert {:ok, %BMI{value: 36.0}} = BMI.new(36)   # Class II
      assert {:ok, %BMI{value: 42.0}} = BMI.new(42)   # Class III
    end
  end
end
