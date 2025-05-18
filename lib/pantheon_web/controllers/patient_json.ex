defmodule PantheonWeb.PatientJSON do
  @doc """
  Renders a list of patients.
  """
  def index(%{patients: patients}) do
    %{data: Enum.map(patients, &patient_json/1)}
  end

  @doc """
  Renders a single patient.
  """
  def show(%{patient: patient}) do
    %{data: patient_json(patient)}
  end

  defp patient_json(patient) do
    %{
      patient_id: patient.patient_id,
      first_name: patient.first_name,
      last_name: patient.last_name,
      email: patient.email,
      phone: patient.phone,
      address: patient.address,
      nutritionist_id: patient.nutritionist_id
    }
  end
end
