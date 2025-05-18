defmodule Pantheon.PatientManagement.Services.PatientService do
  @moduledoc """
  Service for managing patients.
  """
  alias Pantheon.CommandedApplication
  alias Pantheon.PatientManagement.Commands.{RegisterPatient, UpdatePatientDetails}
  alias Pantheon.PatientManagement.Projections.PatientProjection
  alias Pantheon.PatientManagement.ValueObjects.{PatientId, ContactDetails}
  alias Pantheon.Repo

  import Ecto.Query

  @doc """
  Registers a new patient.
  """
  @spec register_patient(map()) :: {:ok, String.t()} | {:error, term()}
  def register_patient(attrs) do
    patient_id = PatientId.generate()

    with {:ok, contact_details} <- build_contact_details(attrs),
         {:ok, command} <- build_register_command(patient_id, attrs, contact_details),
         :ok <- CommandedApplication.dispatch(command, consistency: :strong) do
      {:ok, patient_id}
    end
  end

  @doc """
  Updates patient details.
  """
  @spec update_patient(String.t(), map()) :: :ok | {:error, term()}
  def update_patient(patient_id, attrs) do
    with {:ok, _id} <- PatientId.validate(patient_id),
         {:ok, _patient} <- get_patient(patient_id),
         {:ok, contact_details} <- build_contact_details(attrs),
         {:ok, command} <- build_update_command(patient_id, attrs, contact_details),
         :ok <- CommandedApplication.dispatch(command, consistency: :strong) do
      :ok
    end
  end

  @doc """
  Gets a patient by ID.
  """
  @spec get_patient(String.t()) :: {:ok, PatientProjection.t()} | {:error, :not_found}
  def get_patient(patient_id) do
    case Repo.get(PatientProjection, patient_id) do
      nil -> {:error, :patient_not_found}
      patient -> {:ok, patient}
    end
  end

  @doc """
  Lists patients for a nutritionist.
  """
  @spec list_patients_by_nutritionist(String.t(), keyword()) :: [PatientProjection.t()]
  def list_patients_by_nutritionist(nutritionist_id, opts \\ []) do
    limit = Keyword.get(opts, :limit, 50)
    offset = Keyword.get(opts, :offset, 0)

    from(p in PatientProjection,
      where: p.nutritionist_id == ^nutritionist_id,
      order_by: [asc: p.last_name, asc: p.first_name],
      limit: ^limit,
      offset: ^offset
    )
    |> Repo.all()
  end

  # Private helpers

  defp build_contact_details(%{email: email} = attrs) when is_binary(email) do
    ContactDetails.new(%{
      email: email,
      phone: Map.get(attrs, :phone),
      address: Map.get(attrs, :address)
    })
  end
  defp build_contact_details(_), do: {:error, :email_required}

  defp build_register_command(patient_id, attrs, contact_details) do
    command = %RegisterPatient{
      patient_id: patient_id,
      first_name: Map.get(attrs, :first_name),
      last_name: Map.get(attrs, :last_name),
      date_of_birth: Map.get(attrs, :date_of_birth),
      contact_details: contact_details,
      nutritionist_id: Map.get(attrs, :nutritionist_id)
    }

    {:ok, command}
  end

  defp build_update_command(patient_id, attrs, contact_details) do
    command = %UpdatePatientDetails{
      patient_id: patient_id,
      first_name: Map.get(attrs, :first_name),
      last_name: Map.get(attrs, :last_name),
      contact_details: contact_details
    }

    {:ok, command}
  end
end
