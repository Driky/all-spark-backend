defmodule Pantheon.PatientManagement.Aggregates.PatientTest do
  use ExUnit.Case

  alias Pantheon.PatientManagement.Aggregates.Patient
  alias Pantheon.PatientManagement.Commands.{RegisterPatient, UpdatePatientDetails}
  alias Pantheon.PatientManagement.Events.{PatientRegistered, PatientDetailsUpdated}
  alias Pantheon.PatientManagement.ValueObjects.{PatientId, ContactDetails}

  describe "execute/2 with RegisterPatient command" do
    test "should create a new patient with valid data" do
      patient_id = PatientId.generate()
      {:ok, contact_details} = ContactDetails.new(%{email: "patient@example.com", phone: "123456789"})

      command = %RegisterPatient{
        patient_id: patient_id,
        first_name: "John",
        last_name: "Doe",
        date_of_birth: ~D[1990-01-01],
        contact_details: contact_details,
        nutritionist_id: "nutritionist-123"
      }

      assert {:ok, %PatientRegistered{} = event} = Patient.execute(nil, command)
      assert event.patient_id == patient_id
      assert event.first_name == "John"
      assert event.last_name == "Doe"
      assert event.date_of_birth == ~D[1990-01-01]
      assert event.contact_details == contact_details
      assert event.nutritionist_id == "nutritionist-123"
    end

    test "should reject creating a patient with invalid patient_id" do
      command = %RegisterPatient{
        patient_id: "not-a-uuid",
        first_name: "John",
        last_name: "Doe",
        date_of_birth: ~D[1990-01-01],
        contact_details: %{email: "patient@example.com"},
        nutritionist_id: "nutritionist-123"
      }

      assert {:error, :invalid_patient_id} = Patient.execute(nil, command)
    end

    test "should reject creating a patient with missing required fields" do
      patient_id = PatientId.generate()

      command = %RegisterPatient{
        patient_id: patient_id,
        first_name: "",  # Empty first name
        last_name: "Doe",
        date_of_birth: nil,  # Missing date of birth
        contact_details: nil,  # Missing contact details
        nutritionist_id: "nutritionist-123"
      }

      assert {:error, :invalid_patient_data} = Patient.execute(nil, command)
    end

    test "should reject creating a patient that already exists" do
      patient_id = PatientId.generate()
      existing_patient = %Patient{patient_id: patient_id, first_name: "Existing"}

      command = %RegisterPatient{
        patient_id: patient_id,
        first_name: "John",
        last_name: "Doe",
        date_of_birth: ~D[1990-01-01],
        contact_details: %{email: "patient@example.com"},
        nutritionist_id: "nutritionist-123"
      }

      assert {:error, :patient_already_registered} = Patient.execute(existing_patient, command)
    end
  end

  describe "execute/2 with UpdatePatientDetails command" do
    test "should update patient details" do
      patient_id = PatientId.generate()
      existing_patient = %Patient{
        patient_id: patient_id,
        first_name: "John",
        last_name: "Doe",
        nutritionist_id: "nutritionist-123"
      }

      {:ok, contact_details} = ContactDetails.new(%{
        email: "updated@example.com",
        phone: "987654321",
        address: "123 New Street"
      })

      command = %UpdatePatientDetails{
        patient_id: patient_id,
        first_name: "Johnny",
        last_name: "Smith",
        contact_details: contact_details
      }

      assert {:ok, %PatientDetailsUpdated{} = event} = Patient.execute(existing_patient, command)
      assert event.patient_id == patient_id
      assert event.first_name == "Johnny"
      assert event.last_name == "Smith"
      assert event.contact_details == contact_details
    end

    test "should reject updating non-existent patient" do
      patient_id = PatientId.generate()

      command = %UpdatePatientDetails{
        patient_id: patient_id,
        first_name: "Johnny",
        last_name: "Smith",
        contact_details: %{email: "updated@example.com"}
      }

      assert {:error, :patient_not_found} = Patient.execute(nil, command)
    end
  end

  describe "apply/2" do
    test "should apply PatientRegistered event" do
      patient_id = PatientId.generate()
      {:ok, contact_details} = ContactDetails.new(%{email: "patient@example.com"})

      event = %PatientRegistered{
        patient_id: patient_id,
        first_name: "John",
        last_name: "Doe",
        date_of_birth: ~D[1990-01-01],
        contact_details: contact_details,
        nutritionist_id: "nutritionist-123"
      }

      patient = Patient.apply(nil, event)

      assert patient.patient_id == patient_id
      assert patient.first_name == "John"
      assert patient.last_name == "Doe"
      assert patient.date_of_birth == ~D[1990-01-01]
      assert patient.contact_details == contact_details
      assert patient.nutritionist_id == "nutritionist-123"
    end

    test "should apply PatientDetailsUpdated event" do
      patient_id = PatientId.generate()
      existing_patient = %Patient{
        patient_id: patient_id,
        first_name: "John",
        last_name: "Doe",
        nutritionist_id: "nutritionist-123"
      }

      {:ok, contact_details} = ContactDetails.new(%{email: "updated@example.com"})

      event = %PatientDetailsUpdated{
        patient_id: patient_id,
        first_name: "Johnny",
        last_name: "Smith",
        contact_details: contact_details
      }

      updated_patient = Patient.apply(existing_patient, event)

      assert updated_patient.patient_id == patient_id
      assert updated_patient.first_name == "Johnny"
      assert updated_patient.last_name == "Smith"
      assert updated_patient.contact_details == contact_details
      assert updated_patient.nutritionist_id == "nutritionist-123"  # unchanged
    end
  end
end
