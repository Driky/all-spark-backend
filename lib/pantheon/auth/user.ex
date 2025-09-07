defmodule Allspark.Auth.User do
  @moduledoc """
  Represents an authenticated user.
  """
  use TypedStruct

  typedstruct do
    field :id, String.t(), enforce: true
    field :email, String.t(), enforce: true
    field :full_name, String.t()
    field :role, String.t()
    field :metadata, map(), default: %{}
  end

  @doc """
  Creates a new user from Supabase user data.
  """
  @spec from_supabase(map()) :: t()
  def from_supabase(user_data) do
    metadata = user_data["user_metadata"] || %{}

    %__MODULE__{
      id: user_data["id"] || user_data["sub"],
      email: user_data["email"],
      full_name: metadata["full_name"],
      role: metadata["role"],
      metadata: metadata
    }
  end
end
