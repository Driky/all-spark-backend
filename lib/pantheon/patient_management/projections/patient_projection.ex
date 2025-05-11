defmodule Pantheon.PatientManagement.Projections.PatientProjection do
  @moduledoc """
  Schema for the patient projection.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:patient_id, :binary_id, autogenerate: false}
  @derive {Phoenix.Param, key: :patient_id}
  schema "patients" do
    field :first_name, :string
    field :last_name, :string
    field :date_of_birth, :date
    field :email, :string
    field :phone, :string
    field :address, :string
    field :nutritionist_id, :string

    timestamps()
  end

  def changeset(projection, attrs) do
    projection
    |> cast(attrs, [:patient_id, :first_name, :last_name, :date_of_birth,
                   :email, :phone, :address, :nutritionist_id])
    |> validate_required([:patient_id, :first_name, :last_name, :email, :nutritionist_id])
  end
end
