# test/pantheon/biometric_tracking/value_objects/metabolic_age_test.exs

defmodule Pantheon.BiometricTracking.ValueObjects.MetabolicAgeTest do
  use ExUnit.Case, async: true

  alias Pantheon.BiometricTracking.ValueObjects.MetabolicAge

  describe "new/1" do
    test "creates metabolic age from valid integer years" do
      assert {:ok, %MetabolicAge{years: 25}} = MetabolicAge.new(25)
    end

    test "accepts minimum reasonable age" do
      assert {:ok, %MetabolicAge{years: 10}} = MetabolicAge.new(10)
    end

    test "accepts maximum reasonable age" do
      assert {:ok, %MetabolicAge{years: 150}} = MetabolicAge.new(150)
    end

    test "handles typical adult metabolic ages" do
      # Young adult range
      assert {:ok, %MetabolicAge{years: 18}} = MetabolicAge.new(18)
      assert {:ok, %MetabolicAge{years: 25}} = MetabolicAge.new(25)
      assert {:ok, %MetabolicAge{years: 30}} = MetabolicAge.new(30)

      # Middle age range
      assert {:ok, %MetabolicAge{years: 35}} = MetabolicAge.new(35)
      assert {:ok, %MetabolicAge{years: 45}} = MetabolicAge.new(45)
      assert {:ok, %MetabolicAge{years: 55}} = MetabolicAge.new(55)

      # Older adult range
      assert {:ok, %MetabolicAge{years: 65}} = MetabolicAge.new(65)
      assert {:ok, %MetabolicAge{years: 75}} = MetabolicAge.new(75)
      assert {:ok, %MetabolicAge{years: 85}} = MetabolicAge.new(85)
    end

    test "handles metabolic ages for different fitness levels" do
      # Very fit person might have lower metabolic age
      assert {:ok, %MetabolicAge{years: 20}} = MetabolicAge.new(20)
      assert {:ok, %MetabolicAge{years: 22}} = MetabolicAge.new(22)

      # Average fitness
      assert {:ok, %MetabolicAge{years: 35}} = MetabolicAge.new(35)
      assert {:ok, %MetabolicAge{years: 40}} = MetabolicAge.new(40)

      # Lower fitness might result in higher metabolic age
      assert {:ok, %MetabolicAge{years: 50}} = MetabolicAge.new(50)
      assert {:ok, %MetabolicAge{years: 60}} = MetabolicAge.new(60)
    end

    test "handles edge cases for children and elderly" do
      # Children (rare but possible in specialized medical contexts)
      assert {:ok, %MetabolicAge{years: 12}} = MetabolicAge.new(12)
      assert {:ok, %MetabolicAge{years: 15}} = MetabolicAge.new(15)

      # Very elderly
      assert {:ok, %MetabolicAge{years: 90}} = MetabolicAge.new(90)
      assert {:ok, %MetabolicAge{years: 100}} = MetabolicAge.new(100)
      assert {:ok, %MetabolicAge{years: 120}} = MetabolicAge.new(120)
    end

    test "rejects zero and negative ages" do
      assert {:error, :invalid_metabolic_age} = MetabolicAge.new(0)
      assert {:error, :invalid_metabolic_age} = MetabolicAge.new(-1)
      assert {:error, :invalid_metabolic_age} = MetabolicAge.new(-5)
    end

    test "rejects ages below minimum limit" do
      assert {:error, :invalid_metabolic_age} = MetabolicAge.new(9)
      assert {:error, :invalid_metabolic_age} = MetabolicAge.new(5)
      assert {:error, :invalid_metabolic_age} = MetabolicAge.new(1)
    end

    test "rejects ages above maximum limit" do
      assert {:error, :invalid_metabolic_age} = MetabolicAge.new(151)
      assert {:error, :invalid_metabolic_age} = MetabolicAge.new(200)
      assert {:error, :invalid_metabolic_age} = MetabolicAge.new(999)
    end

    test "rejects non-integer values" do
      assert {:error, :invalid_metabolic_age} = MetabolicAge.new(25.5)
      assert {:error, :invalid_metabolic_age} = MetabolicAge.new(30.1)
      assert {:error, :invalid_metabolic_age} = MetabolicAge.new(22.9)
    end

    test "rejects non-numeric values" do
      assert {:error, :invalid_metabolic_age} = MetabolicAge.new("25")
      assert {:error, :invalid_metabolic_age} = MetabolicAge.new("thirty")
      assert {:error, :invalid_metabolic_age} = MetabolicAge.new(nil)
      assert {:error, :invalid_metabolic_age} = MetabolicAge.new(:invalid)
      assert {:error, :invalid_metabolic_age} = MetabolicAge.new(%{})
      assert {:error, :invalid_metabolic_age} = MetabolicAge.new([])
    end

    test "rejects special float values" do
      assert {:error, :invalid_metabolic_age} = MetabolicAge.new(:infinity)
      assert {:error, :invalid_metabolic_age} = MetabolicAge.new(:negative_infinity)
      assert {:error, :invalid_metabolic_age} = MetabolicAge.new(:nan)
    end
  end

  describe "equality and comparison" do
    test "metabolic ages with same value are equal" do
      {:ok, age1} = MetabolicAge.new(30)
      {:ok, age2} = MetabolicAge.new(30)

      assert age1 == age2
    end

    test "metabolic ages with different values are not equal" do
      {:ok, age1} = MetabolicAge.new(30)
      {:ok, age2} = MetabolicAge.new(35)

      assert age1 != age2
    end
  end

  describe "boundary conditions" do
    test "handles edge case of minimum metabolic age" do
      assert {:ok, %MetabolicAge{years: 10}} = MetabolicAge.new(10)
    end

    test "handles edge case of maximum metabolic age" do
      assert {:ok, %MetabolicAge{years: 150}} = MetabolicAge.new(150)
    end

    test "rejects age just above maximum" do
      assert {:error, :invalid_metabolic_age} = MetabolicAge.new(151)
    end

    test "rejects age just below minimum" do
      assert {:error, :invalid_metabolic_age} = MetabolicAge.new(9)
    end

    test "handles ages at boundaries" do
      assert {:ok, %MetabolicAge{years: 10}} = MetabolicAge.new(10)
      assert {:ok, %MetabolicAge{years: 150}} = MetabolicAge.new(150)
    end
  end

  describe "fitness and health scenarios" do
    test "supports metabolic age for highly fit individuals" do
      # Athlete might have metabolic age lower than chronological age
      assert {:ok, %MetabolicAge{years: 25}} = MetabolicAge.new(25)
      assert {:ok, %MetabolicAge{years: 28}} = MetabolicAge.new(28)
    end

    test "supports metabolic age for average fitness" do
      # Metabolic age close to chronological age
      assert {:ok, %MetabolicAge{years: 35}} = MetabolicAge.new(35)
      assert {:ok, %MetabolicAge{years: 42}} = MetabolicAge.new(42)
    end

    test "supports metabolic age for lower fitness" do
      # Metabolic age higher than chronological age
      assert {:ok, %MetabolicAge{years: 50}} = MetabolicAge.new(50)
      assert {:ok, %MetabolicAge{years: 65}} = MetabolicAge.new(65)
    end

    test "supports metabolic age comparisons across age groups" do
      # Young person with poor fitness
      assert {:ok, %MetabolicAge{years: 35}} = MetabolicAge.new(35)  # 25-year-old with metabolic age 35

      # Older person with excellent fitness
      assert {:ok, %MetabolicAge{years: 30}} = MetabolicAge.new(30)  # 50-year-old with metabolic age 30

      # Very fit elderly person
      assert {:ok, %MetabolicAge{years: 45}} = MetabolicAge.new(45)  # 70-year-old with metabolic age 45
    end
  end
end
