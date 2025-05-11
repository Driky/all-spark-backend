defmodule Pantheon.PatientManagement.Commands.UpdatePatientDetails do
  @moduledoc """
  Command to update patient details.
  """
  use TypedStruct

  alias Pantheon.PatientManagement.ValueObjects.{PatientId, ContactDetails}

  typedstruct do
    field :patient_id, PatientId.t(), enforce: true
    field :first_name, String.t()
    field :last_name, String.t()
    field :contact_details, ContactDetails.t()
  end
end
