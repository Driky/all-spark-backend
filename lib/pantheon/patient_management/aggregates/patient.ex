defmodule Pantheon.PatientManagement.Aggregates.Patient do
  @moduledoc """
  Patient aggregate root.
  """
  use TypedStruct

  alias Pantheon.PatientManagement.Commands.{RegisterPatient, UpdatePatientDetails}
  alias Pantheon.PatientManagement.Events.{PatientRegistered, PatientDetailsUpdated}
  alias Pantheon.PatientManagement.ValueObjects.{PatientId, ContactDetails}

  typedstruct do
    field :patient_id, PatientId.t()
    field :first_name, String.t()
    field :last_name, String.t()
    field :date_of_birth, Date.t()
    field :contact_details, ContactDetails.t()
    field :nutritionist_id, String.t()
  end

  # Command handlers

  @spec execute(t() | nil, RegisterPatient.t()) :: {:ok, PatientRegistered.t()} | {:error, atom()}
  def execute(nil, %RegisterPatient{} = command) do
    with {:ok, _} <- validate_patient_id(command.patient_id),
         :ok <- validate_required_fields(command) do
      {:ok, %PatientRegistered{
        patient_id: command.patient_id,
        first_name: command.first_name,
        last_name: command.last_name,
        date_of_birth: command.date_of_birth,
        contact_details: command.contact_details,
        nutritionist_id: command.nutritionist_id
      }}
    end
  end

  def execute(%__MODULE__{}, %RegisterPatient{}) do
    {:error, :patient_already_registered}
  end

  @spec execute(t() | nil, UpdatePatientDetails.t()) :: {:ok, PatientDetailsUpdated.t()} | {:error, atom()}
  def execute(nil, %UpdatePatientDetails{}) do
    {:error, :patient_not_found}
  end

  def execute(%__MODULE__{} = patient, %UpdatePatientDetails{} = command) do
    with {:ok, _} <- validate_patient_id(command.patient_id) do
      {:ok, %PatientDetailsUpdated{
        patient_id: patient.patient_id,
        first_name: command.first_name || patient.first_name,
        last_name: command.last_name || patient.last_name,
        contact_details: command.contact_details || patient.contact_details
      }}
    end
  end

  # Event handlers

  @spec apply(t() | nil, PatientRegistered.t()) :: t()
  def apply(_, %PatientRegistered{} = event) do
    %__MODULE__{
      patient_id: event.patient_id,
      first_name: event.first_name,
      last_name: event.last_name,
      date_of_birth: event.date_of_birth,
      contact_details: event.contact_details,
      nutritionist_id: event.nutritionist_id
    }
  end

  @spec apply(t(), PatientDetailsUpdated.t()) :: t()
  def apply(%__MODULE__{} = patient, %PatientDetailsUpdated{} = event) do
    %__MODULE__{patient |
      first_name: event.first_name || patient.first_name,
      last_name: event.last_name || patient.last_name,
      contact_details: event.contact_details || patient.contact_details
    }
  end

  # Private helper functions

  defp validate_patient_id(patient_id) do
    PatientId.validate(patient_id)
  end

  defp validate_required_fields(%RegisterPatient{} = command) do
    cond do
      is_nil(command.first_name) || String.trim(command.first_name) == "" ->
        {:error, :invalid_patient_data}
      is_nil(command.last_name) || String.trim(command.last_name) == "" ->
        {:error, :invalid_patient_data}
      is_nil(command.date_of_birth) ->
        {:error, :invalid_patient_data}
      is_nil(command.contact_details) ->
        {:error, :invalid_patient_data}
      is_nil(command.nutritionist_id) || String.trim(command.nutritionist_id) == "" ->
        {:error, :invalid_patient_data}
      true ->
        :ok
    end
  end
end
