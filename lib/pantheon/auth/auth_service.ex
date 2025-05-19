defmodule Pantheon.Auth.AuthService do
  @moduledoc """
  Handles authentication via Supabase.
  """

  alias Pantheon.Supabase.Client

  @doc """
  Signs up a new user with email and password.
  """
  @spec sign_up(String.t(), String.t()) :: {:ok, map()} | {:error, String.t()}
  def sign_up(email, password) do
    # Get the GoTrue module (real or mocked)
    gotrue = Application.get_env(:pantheon, :gotrue_module, Supabase.GoTrue)
    client = Application.get_env(:pantheon, :supabase_client, Client)

    params = %{email: email, password: password}

    case gotrue.sign_up_with_password(client, params) do
      {:ok, response} ->
        {:ok, %{
          token: response["access_token"],
          user_id: response["user"]["id"]
        }}
      {:error, error} ->
        {:error, error["message"] || "Signup failed"}
    end
  end

  @doc """
  Signs in a user with email and password.
  """
  @spec sign_in(String.t(), String.t()) :: {:ok, map()} | {:error, String.t()}
  def sign_in(email, password) do
    # Get the GoTrue module (real or mocked)
    gotrue = Application.get_env(:pantheon, :gotrue_module, Supabase.GoTrue)
    client = Application.get_env(:pantheon, :supabase_client, Client)

    params = %{email: email, password: password}

    case gotrue.sign_in_with_password(client, params) do
      {:ok, response} ->
        {:ok, %{
          token: response["access_token"],
          user_id: response["user"]["id"]
        }}
      {:error, error} ->
        {:error, error["message"] || "Invalid credentials"}
    end
  end
end
