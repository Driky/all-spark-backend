defmodule Pantheon.PatientManagement.Router do
  @moduledoc """
  Command router for the Patient Management bounded context.
  """
  use Commanded.Commands.Router

  alias Pantheon.PatientManagement.Aggregates.Patient
  alias Pantheon.PatientManagement.Commands.{RegisterPatient, UpdatePatientDetails}
  alias Pantheon.PatientManagement.Handlers.PatientCommandHandler

  dispatch [RegisterPatient, UpdatePatientDetails],
    to: PatientCommandHandler,
    aggregate: Patient,
    identity: :patient_id
end
