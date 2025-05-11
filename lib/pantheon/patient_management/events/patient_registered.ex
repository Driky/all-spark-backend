defmodule Pantheon.PatientManagement.Events.PatientRegistered do
  @moduledoc """
  Event emitted when a new patient is registered.
  """
  use TypedStruct

  alias Pantheon.PatientManagement.ValueObjects.{PatientId, ContactDetails}

  @derive Jason.Encoder
  typedstruct do
    field :patient_id, PatientId.t(), enforce: true
    field :first_name, String.t(), enforce: true
    field :last_name, String.t(), enforce: true
    field :date_of_birth, Date.t()
    field :contact_details, ContactDetails.t(), enforce: true
    field :nutritionist_id, String.t(), enforce: true
    field :version, integer(), default: 1
  end
end
