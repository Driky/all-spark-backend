defmodule Pantheon.PatientManagement.Events.PatientDetailsUpdated do
  @moduledoc """
  Event emitted when patient details are updated.
  """
  use TypedStruct

  alias Pantheon.PatientManagement.ValueObjects.{PatientId, ContactDetails}

  @derive Jason.Encoder
  typedstruct do
    field :patient_id, PatientId.t(), enforce: true
    field :first_name, String.t()
    field :last_name, String.t()
    field :contact_details, ContactDetails.t()
    field :version, integer(), default: 1
  end
end
