defmodule Pantheon.PatientManagement.Projections.PatientProjector do
  @moduledoc """
  Projects patient events to the patient read model.
  """
  use Commanded.Projections.Ecto,
    application: Pantheon.CommandedApplication,
    name: "PatientManagement.PatientProjector",
    consistency: :strong

  alias Pantheon.PatientManagement.Events.{PatientRegistered, PatientDetailsUpdated}
  alias Pantheon.PatientManagement.Projections.PatientProjection
  alias Pantheon.Repo

  project %PatientRegistered{} = event, _metadata, fn multi ->
    contact_details = event.contact_details

    patient_data = %{
      patient_id: event.patient_id,
      first_name: event.first_name,
      last_name: event.last_name,
      date_of_birth: event.date_of_birth,
      email: contact_details.email,
      phone: contact_details.phone,
      address: contact_details.address,
      nutritionist_id: event.nutritionist_id
    }

    Ecto.Multi.insert(multi, :patient, PatientProjection.changeset(%PatientProjection{}, patient_data))
  end

  project %PatientDetailsUpdated{} = event, _metadata, fn multi ->
    patient = Repo.get!(PatientProjection, event.patient_id)
    contact_details = event.contact_details || %{}

    updates = %{}
      |> maybe_update(:first_name, event.first_name)
      |> maybe_update(:last_name, event.last_name)
      |> maybe_update(:email, contact_details.email)
      |> maybe_update(:phone, contact_details.phone)
      |> maybe_update(:address, contact_details.address)

    if map_size(updates) > 0 do
      Ecto.Multi.update(
        multi,
        :patient,
        PatientProjection.changeset(patient, updates)
      )
    else
      multi
    end
  end

  defp maybe_update(map, _key, nil), do: map
  defp maybe_update(map, key, value), do: Map.put(map, key, value)
end
