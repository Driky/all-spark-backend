# test/pantheon/patient_management/projections/patient_projector_test.exs
defmodule Pantheon.PatientManagement.Projections.PatientProjectorTest do
  use Pantheon.DataCase

  alias Pantheon.PatientManagement.Events.{PatientRegistered, PatientDetailsUpdated}
  alias Pantheon.PatientManagement.Projections.{PatientProjection, PatientProjector}
  alias Pantheon.PatientManagement.ValueObjects.{PatientId, ContactDetails}
  alias Pantheon.Repo

  describe "handle/2 with PatientRegistered" do
    test "creates a new patient projection" do
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

      # Include the required metadata format
      metadata = %{
        event_number: 1,
        handler_name: "PatientManagement.PatientProjector"
      }

      assert :ok = PatientProjector.handle(event, metadata)

      projection = Repo.get(PatientProjection, patient_id)
      assert projection != nil
      assert projection.patient_id == patient_id
      assert projection.first_name == "John"
      assert projection.last_name == "Doe"
      assert projection.date_of_birth == ~D[1990-01-01]
      assert projection.email == "patient@example.com"
      assert projection.nutritionist_id == "nutritionist-123"
    end
  end

  describe "handle/2 with PatientDetailsUpdated" do
    test "updates an existing patient projection" do
      # First create a patient
      patient_id = PatientId.generate()

      %PatientProjection{}
      |> PatientProjection.changeset(%{
        patient_id: patient_id,
        first_name: "John",
        last_name: "Doe",
        date_of_birth: ~D[1990-01-01],
        email: "patient@example.com",
        nutritionist_id: "nutritionist-123"
      })
      |> Repo.insert!()

      # Then update the patient
      {:ok, updated_contact_details} = ContactDetails.new(%{
        email: "updated@example.com",
        phone: "123456789",
        address: "123 Main St"
      })

      update_event = %PatientDetailsUpdated{
        patient_id: patient_id,
        first_name: "Johnny",
        last_name: "Smith",
        contact_details: updated_contact_details
      }

      # Include the required metadata format
      metadata = %{
        event_number: 2,
        handler_name: "PatientManagement.PatientProjector"
      }

      assert :ok = PatientProjector.handle(update_event, metadata)

      projection = Repo.get(PatientProjection, patient_id)
      assert projection != nil
      assert projection.patient_id == patient_id
      assert projection.first_name == "Johnny"
      assert projection.last_name == "Smith"
      assert projection.email == "updated@example.com"
      assert projection.phone == "123456789"
      assert projection.address == "123 Main St"
      assert projection.nutritionist_id == "nutritionist-123"  # Unchanged
    end
  end
end
