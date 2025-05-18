defmodule PantheonWeb.PatientControllerTest do
  use PantheonWeb.ConnCase

  import Pantheon.DataCase

  alias Pantheon.PatientManagement.Projections.PatientProjection
  alias Pantheon.PatientManagement.Services.PatientService

  # We'll use this for testing
  @create_attrs %{
    first_name: "John",
    last_name: "Doe",
    date_of_birth: ~D[1990-01-01],
    email: "john.doe@example.com",
    phone: "123456789",
    address: "123 Main St",
    nutritionist_id: "nutritionist-123"
  }

  @update_attrs %{
    first_name: "Johnny",
    last_name: "Smith",
    email: "johnny.smith@example.com",
    phone: "987654321"
  }

  @invalid_attrs %{
    first_name: nil,
    last_name: nil,
    email: nil,
    nutritionist_id: nil
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all patients", %{conn: conn} do
      # Create a patient first
      {:ok, patient_id} = PatientService.register_patient(@create_attrs)

      conn = get(conn, ~p"/api/patients")

      assert %{"data" => patients} = json_response(conn, 200)
      assert length(patients) > 0

      # Find our patient in the list
      patient = Enum.find(patients, fn p -> p["patient_id"] == patient_id end)
      assert patient != nil
      assert patient["first_name"] == @create_attrs.first_name
    end
  end

  describe "create patient" do
    test "renders patient when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/patients", patient: @create_attrs)
      assert %{"patient_id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/patients/#{id}")
      assert %{
               "patient_id" => ^id,
               "first_name" => "John",
               "last_name" => "Doe",
               "email" => "john.doe@example.com"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/patients", patient: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update patient" do
    setup [:create_patient]

    test "renders patient when data is valid", %{conn: conn, patient: %{patient_id: id}} do
      conn = put(conn, ~p"/api/patients/#{id}", patient: @update_attrs)
      assert %{"patient_id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/patients/#{id}")
      assert %{
               "patient_id" => ^id,
               "first_name" => "Johnny",
               "last_name" => "Smith",
               "email" => "johnny.smith@example.com"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, patient: %{patient_id: id}} do
      conn = put(conn, ~p"/api/patients/#{id}", patient: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "list by nutritionist" do
    test "lists all patients for a nutritionist", %{conn: conn} do
      # Create patients for a specific nutritionist
      nutritionist_id = "nutritionist-#{Ecto.UUID.generate()}"

      patients = [
        %{first_name: "Alice", last_name: "Smith", email: "alice@example.com",
          date_of_birth: ~D[1990-01-01], nutritionist_id: nutritionist_id},
        %{first_name: "Bob", last_name: "Jones", email: "bob@example.com",
          date_of_birth: ~D[1991-02-02], nutritionist_id: nutritionist_id}
      ]

      # Register the patients
      Enum.each(patients, &PatientService.register_patient/1)

      # Also create a patient for a different nutritionist
      PatientService.register_patient(%{
        first_name: "Charlie",
        last_name: "Brown",
        email: "charlie@example.com",
        date_of_birth: ~D[1992-03-03],
        nutritionist_id: "different-nutritionist"
      })

      # Test the endpoint
      conn = get(conn, ~p"/api/nutritionists/#{nutritionist_id}/patients")

      assert %{"data" => patients_list} = json_response(conn, 200)
      assert length(patients_list) == 2

      # All patients should belong to our nutritionist
      assert Enum.all?(patients_list, fn p -> p["nutritionist_id"] == nutritionist_id end)
    end
  end

  defp create_patient(_) do
    {:ok, patient_id} = PatientService.register_patient(@create_attrs)
    {:ok, patient} = PatientService.get_patient(patient_id)
    %{patient: patient}
  end
end
