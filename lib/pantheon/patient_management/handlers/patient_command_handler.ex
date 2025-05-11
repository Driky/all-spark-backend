defmodule Pantheon.PatientManagement.Handlers.PatientCommandHandler do
  @moduledoc """
  Handles commands for the Patient aggregate.
  """
  @behaviour Commanded.Commands.Handler

  alias Pantheon.PatientManagement.Aggregates.Patient
  alias Pantheon.PatientManagement.Commands.{RegisterPatient, UpdatePatientDetails}

  @impl true
  def handle(%Patient{} = aggregate, %RegisterPatient{} = command) do
    Patient.execute(aggregate, command)
  end

  @impl true
  def handle(%Patient{} = aggregate, %UpdatePatientDetails{} = command) do
    Patient.execute(aggregate, command)
  end
end
