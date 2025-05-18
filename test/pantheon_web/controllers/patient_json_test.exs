defmodule PantheonWeb.PatientJSONTest do
  use PantheonWeb.ConnCase, async: true

  alias PantheonWeb.PatientJSON

  test "index.json renders a list of patients" do
    patients = [
      %{
        patient_id: "123",
        first_name: "John",
        last_name: "Doe",
        email: "john@example.com",
        phone: "123456789",
        address: "123 Main St",
        nutritionist_id: "nutri-123"
      },
      %{
        patient_id: "456",
        first_name: "Jane",
        last_name: "Smith",
        email: "jane@example.com",
        phone: nil,
        address: nil,
        nutritionist_id: "nutri-123"
      }
    ]

    rendered_patients = PatientJSON.index(%{patients: patients})

    assert rendered_patients == %{
      data: [
        %{
          patient_id: "123",
          first_name: "John",
          last_name: "Doe",
          email: "john@example.com",
          phone: "123456789",
          address: "123 Main St",
          nutritionist_id: "nutri-123"
        },
        %{
          patient_id: "456",
          first_name: "Jane",
          last_name: "Smith",
          email: "jane@example.com",
          phone: nil,
          address: nil,
          nutritionist_id: "nutri-123"
        }
      ]
    }
  end

  test "show.json renders a single patient" do
    patient = %{
      patient_id: "123",
      first_name: "John",
      last_name: "Doe",
      email: "john@example.com",
      phone: "123456789",
      address: "123 Main St",
      nutritionist_id: "nutri-123"
    }

    rendered_patient = PatientJSON.show(%{patient: patient})

    assert rendered_patient == %{
      data: %{
        patient_id: "123",
        first_name: "John",
        last_name: "Doe",
        email: "john@example.com",
        phone: "123456789",
        address: "123 Main St",
        nutritionist_id: "nutri-123"
      }
    }
  end
end
