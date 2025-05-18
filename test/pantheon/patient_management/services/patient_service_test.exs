defmodule Pantheon.PatientManagement.Services.PatientServiceTest do
  use Pantheon.DataCase

  alias Pantheon.PatientManagement.Services.PatientService
  alias Pantheon.PatientManagement.Projections.PatientProjection
  alias Pantheon.Repo

  describe "register_patient/1" do
    test "successfully registers a patient" do
      attrs = %{
        first_name: "John",
        last_name: "Doe",
        date_of_birth: ~D[1990-01-01],
        email: "john.doe@example.com",
        phone: "123456789",
        address: "123 Main St",
        nutritionist_id: "nutritionist-123"
      }

      assert {:ok, patient_id} = PatientService.register_patient(attrs)
      assert {:ok, patient} = PatientService.get_patient(patient_id)
      assert patient.first_name == "John"
      assert patient.last_name == "Doe"
      assert patient.email == "john.doe@example.com"
    end

    test "returns error when required fields are missing" do
      # Missing email
      attrs = %{
        first_name: "John",
        last_name: "Doe",
        nutritionist_id: "nutritionist-123"
      }

      assert {:error, :email_required} = PatientService.register_patient(attrs)
    end
  end

  describe "update_patient/2" do
    setup do
      # Create a patient first
      attrs = %{
        first_name: "John",
        last_name: "Doe",
        date_of_birth: ~D[1990-01-01],
        email: "john.doe@example.com",
        nutritionist_id: "nutritionist-123"
      }

      {:ok, patient_id} = PatientService.register_patient(attrs)
      {:ok, %{patient_id: patient_id}}
    end

    test "successfully updates a patient", %{patient_id: patient_id} do
      update_attrs = %{
        first_name: "Johnny",
        last_name: "Smith",
        email: "johnny.smith@example.com",
        phone: "987654321"
      }

      assert :ok = PatientService.update_patient(patient_id, update_attrs)
      assert {:ok, patient} = PatientService.get_patient(patient_id)
      assert patient.first_name == "Johnny"
      assert patient.last_name == "Smith"
      assert patient.email == "johnny.smith@example.com"
      assert patient.phone == "987654321"
    end

    test "returns error when patient does not exist" do
      non_existent_id = Ecto.UUID.generate()

      assert {:error, :patient_not_found} = PatientService.update_patient(non_existent_id, %{first_name: "Test"})
    end
  end

  describe "list_patients_by_nutritionist/2" do
    setup do
      # Create several patients for the same nutritionist
      nutritionist_id = "nutritionist-123"

      patients = [
        %{first_name: "Alice", last_name: "Smith", email: "alice@example.com",
          date_of_birth: ~D[1990-01-01], nutritionist_id: nutritionist_id},
        %{first_name: "Bob", last_name: "Jones", email: "bob@example.com",
          date_of_birth: ~D[1991-02-02], nutritionist_id: nutritionist_id},
        %{first_name: "Charlie", last_name: "Brown", email: "charlie@example.com",
          date_of_birth: ~D[1992-03-03], nutritionist_id: nutritionist_id}
      ]

      Enum.each(patients, &PatientService.register_patient/1)

      # Create a patient for a different nutritionist
      PatientService.register_patient(%{
        first_name: "David",
        last_name: "Miller",
        email: "david@example.com",
        nutritionist_id: "nutritionist-456"
      })

      {:ok, %{nutritionist_id: nutritionist_id}}
    end

    test "returns all patients for a nutritionist", %{nutritionist_id: nutritionist_id} do
      patients = PatientService.list_patients_by_nutritionist(nutritionist_id)

      assert length(patients) == 3
      assert Enum.all?(patients, &(&1.nutritionist_id == nutritionist_id))
    end

    test "returns empty list for nutritionist with no patients" do
      patients = PatientService.list_patients_by_nutritionist("non-existent-nutritionist")

      assert patients == []
    end

    test "respects limit and offset options", %{nutritionist_id: nutritionist_id} do
      # Get with limit 2
      patients = PatientService.list_patients_by_nutritionist(nutritionist_id, limit: 2)
      assert length(patients) == 2

      # Get with offset 2, should get 1 remaining patient
      patients = PatientService.list_patients_by_nutritionist(nutritionist_id, offset: 2, limit: 10)
      assert length(patients) == 1
    end
  end
end
