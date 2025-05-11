defmodule Pantheon.PatientManagement.Commands.RegisterPatient do
  @moduledoc """
  Command to register a new patient.
  """
  use TypedStruct
  alias Pantheon.PatientManagement.ValueObjects.{PatientId, ContactDetails}

  typedstruct do
    field :patient_id, PatientId.t(), enforce: true
    field :first_name, String.t(), enforce: true
    field :last_name, String.t(), enforce: true
    field :date_of_birth, Date.t()
    field :contact_details, ContactDetails.t(), enforce: true
    field :nutritionist_id, String.t(), enforce: true
  end
end
