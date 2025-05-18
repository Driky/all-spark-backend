defmodule Pantheon.PatientManagement.ValueObjects.ContactDetails do
  @moduledoc """
  Value object representing contact details for a patient.
  """
  use TypedStruct

  @derive Jason.Encoder

  alias Pantheon.PatientManagement.ValueObjects.Email

  typedstruct do
    field :email, Email.t(), enforce: true
    field :phone, String.t()
    field :address, String.t()
  end

  @doc """
  Creates a new ContactDetails value object.
  """
  @spec new(map()) :: {:ok, t()} | {:error, atom()}
  def new(%{email: email} = attrs) do
    with {:ok, validated_email} <- Email.validate(email) do
      contact_details = %__MODULE__{
        email: validated_email,
        phone: Map.get(attrs, :phone),
        address: Map.get(attrs, :address)
      }

      {:ok, contact_details}
    end
  end
  def new(_), do: {:error, :email_required}
end
