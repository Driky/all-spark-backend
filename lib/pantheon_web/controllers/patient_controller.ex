defmodule PantheonWeb.PatientController do
  use PantheonWeb, :controller

  alias Pantheon.PatientManagement.Services.PatientService

  action_fallback PantheonWeb.FallbackController

  def index(conn, _params) do
    # This would be replaced with proper auth later
    # For now, mock a nutritionist ID
    nutritionist_id = "nutritionist-123"
    patients = PatientService.list_patients_by_nutritionist(nutritionist_id)
    render(conn, :index, patients: patients)
  end

  def create(conn, %{"patient" => patient_params}) do
    # Convert string keys to atoms for our service layer
    attrs = Map.new(patient_params, fn {k, v} -> {String.to_existing_atom(k), v} end)

    with {:ok, patient_id} <- PatientService.register_patient(attrs),
         {:ok, patient} <- PatientService.get_patient(patient_id) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/patients/#{patient_id}")
      |> render(:show, patient: patient)
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, patient} <- PatientService.get_patient(id) do
      render(conn, :show, patient: patient)
    end
  end

  def update(conn, %{"id" => id, "patient" => patient_params}) do
    # Convert string keys to atoms for our service layer
    attrs = Map.new(patient_params, fn {k, v} -> {String.to_existing_atom(k), v} end)

    with :ok <- PatientService.update_patient(id, attrs),
         {:ok, patient} <- PatientService.get_patient(id) do
      render(conn, :show, patient: patient)
    end
  end

  def list_by_nutritionist(conn, %{"nutritionist_id" => nutritionist_id}) do
    patients = PatientService.list_patients_by_nutritionist(nutritionist_id)
    render(conn, :index, patients: patients)
  end
end
