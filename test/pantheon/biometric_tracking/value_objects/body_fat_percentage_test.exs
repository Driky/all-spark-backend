defmodule Pantheon.BiometricTracking.ValueObjects.BodyFatPercentageTest do
  use ExUnit.Case, async: true

  alias Pantheon.BiometricTracking.ValueObjects.BodyFatPercentage

  describe "new/1" do
    test "creates body fat percentage from valid integer" do
      assert {:ok, %BodyFatPercentage{percentage: 15.0}} = BodyFatPercentage.new(15)
    end

    test "creates body fat percentage from valid float" do
      assert {:ok, %BodyFatPercentage{percentage: 15.5}} = BodyFatPercentage.new(15.5)
    end

    test "accepts minimum value of 0" do
      assert {:ok, %BodyFatPercentage{percentage: percentage}} = BodyFatPercentage.new(0)
      assert percentage == 0.0
    end

    test "accepts maximum value of 100" do
      assert {:ok, %BodyFatPercentage{percentage: 100.0}} = BodyFatPercentage.new(100)
    end

    test "accepts decimal percentages with precision" do
      assert {:ok, %BodyFatPercentage{percentage: 12.75}} = BodyFatPercentage.new(12.75)
      assert {:ok, %BodyFatPercentage{percentage: 8.25}} = BodyFatPercentage.new(8.25)
    end

    test "converts integer to float for consistency" do
      assert {:ok, %BodyFatPercentage{percentage: percentage}} = BodyFatPercentage.new(20)
      assert is_float(percentage)
      assert percentage == 20.0
    end

    test "preserves float precision" do
      assert {:ok, %BodyFatPercentage{percentage: 18.125}} = BodyFatPercentage.new(18.125)
    end

    test "accepts typical body fat percentage ranges" do
      # Essential fat ranges (minimum for health)
      assert {:ok, %BodyFatPercentage{percentage: 2.0}} = BodyFatPercentage.new(2)
      assert {:ok, %BodyFatPercentage{percentage: 5.0}} = BodyFatPercentage.new(5)

      # Athletic ranges
      assert {:ok, %BodyFatPercentage{percentage: 6.0}} = BodyFatPercentage.new(6)
      assert {:ok, %BodyFatPercentage{percentage: 12.0}} = BodyFatPercentage.new(12)
      assert {:ok, %BodyFatPercentage{percentage: 16.0}} = BodyFatPercentage.new(16)
      assert {:ok, %BodyFatPercentage{percentage: 20.0}} = BodyFatPercentage.new(20)

      # Fitness ranges
      assert {:ok, %BodyFatPercentage{percentage: 25.0}} = BodyFatPercentage.new(25)
      assert {:ok, %BodyFatPercentage{percentage: 32.0}} = BodyFatPercentage.new(32)

      # Higher ranges (still medically relevant)
      assert {:ok, %BodyFatPercentage{percentage: 40.0}} = BodyFatPercentage.new(40)
      assert {:ok, %BodyFatPercentage{percentage: 50.0}} = BodyFatPercentage.new(50)
    end

    test "accepts very low percentages for athletes" do
      assert {:ok, %BodyFatPercentage{percentage: 0.5}} = BodyFatPercentage.new(0.5)
      assert {:ok, %BodyFatPercentage{percentage: 1.0}} = BodyFatPercentage.new(1)
    end

    test "rejects negative percentages" do
      assert {:error, :invalid_body_fat_percentage} = BodyFatPercentage.new(-1)
      assert {:error, :invalid_body_fat_percentage} = BodyFatPercentage.new(-0.1)
      assert {:error, :invalid_body_fat_percentage} = BodyFatPercentage.new(-10)
      assert {:error, :invalid_body_fat_percentage} = BodyFatPercentage.new(-0.01)
    end

    test "rejects percentages above 100" do
      assert {:error, :invalid_body_fat_percentage} = BodyFatPercentage.new(100.1)
      assert {:error, :invalid_body_fat_percentage} = BodyFatPercentage.new(101)
      assert {:error, :invalid_body_fat_percentage} = BodyFatPercentage.new(150)
      assert {:error, :invalid_body_fat_percentage} = BodyFatPercentage.new(999)
    end

    test "rejects non-numeric values" do
      assert {:error, :invalid_body_fat_percentage} = BodyFatPercentage.new("15")
      assert {:error, :invalid_body_fat_percentage} = BodyFatPercentage.new("15.5")
      assert {:error, :invalid_body_fat_percentage} = BodyFatPercentage.new(nil)
      assert {:error, :invalid_body_fat_percentage} = BodyFatPercentage.new(:invalid)
      assert {:error, :invalid_body_fat_percentage} = BodyFatPercentage.new(%{})
      assert {:error, :invalid_body_fat_percentage} = BodyFatPercentage.new([])
      assert {:error, :invalid_body_fat_percentage} = BodyFatPercentage.new("high")
    end

    test "rejects special float values" do
      assert {:error, :invalid_body_fat_percentage} = BodyFatPercentage.new(:infinity)
      assert {:error, :invalid_body_fat_percentage} = BodyFatPercentage.new(:negative_infinity)
      assert {:error, :invalid_body_fat_percentage} = BodyFatPercentage.new(:nan)
    end
  end

  describe "equality and comparison" do
    test "body fat percentages with same value are equal" do
      {:ok, bf1} = BodyFatPercentage.new(15.5)
      {:ok, bf2} = BodyFatPercentage.new(15.5)

      assert bf1 == bf2
    end

    test "body fat percentages with different values are not equal" do
      {:ok, bf1} = BodyFatPercentage.new(15.5)
      {:ok, bf2} = BodyFatPercentage.new(16.0)

      assert bf1 != bf2
    end

    test "integer and float representations are equal" do
      {:ok, bf_int} = BodyFatPercentage.new(15)    # Integer input
      {:ok, bf_float} = BodyFatPercentage.new(15.0)  # Float input

      assert bf_int == bf_float
      assert bf_int.percentage == bf_float.percentage
    end
  end

  describe "boundary conditions" do
    test "handles edge case of exactly 0%" do
      assert {:ok, %BodyFatPercentage{percentage: percentage1}} = BodyFatPercentage.new(0.0)
      assert percentage1 == 0.0

      assert {:ok, %BodyFatPercentage{percentage: percentage2}} = BodyFatPercentage.new(0)
      assert percentage2 == 0.0
    end

    test "handles edge case of exactly 100%" do
      assert {:ok, %BodyFatPercentage{percentage: 100.0}} = BodyFatPercentage.new(100.0)
      assert {:ok, %BodyFatPercentage{percentage: 100.0}} = BodyFatPercentage.new(100)
    end

    test "rejects value just above 100%" do
      assert {:error, :invalid_body_fat_percentage} = BodyFatPercentage.new(100.0001)
      assert {:error, :invalid_body_fat_percentage} = BodyFatPercentage.new(100.01)
    end

    test "rejects value just below 0%" do
      assert {:error, :invalid_body_fat_percentage} = BodyFatPercentage.new(-0.0001)
      assert {:error, :invalid_body_fat_percentage} = BodyFatPercentage.new(-0.01)
    end

    test "handles very small positive percentages" do
      assert {:ok, %BodyFatPercentage{percentage: 0.01}} = BodyFatPercentage.new(0.01)
      assert {:ok, %BodyFatPercentage{percentage: 0.1}} = BodyFatPercentage.new(0.1)
    end

    test "handles values very close to 100%" do
      assert {:ok, %BodyFatPercentage{percentage: 99.99}} = BodyFatPercentage.new(99.99)
      assert {:ok, %BodyFatPercentage{percentage: 99.9}} = BodyFatPercentage.new(99.9)
    end
  end
end
