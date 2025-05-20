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
    clientModule = Application.get_env(:pantheon, :supabase_client, Client)
    {:ok, client} = clientModule.get_client()

    params = %{email: email, password: password}

    case gotrue.sign_up(client, params) do
      {:ok, response} ->
        IO.write("response: " <> inspect(response))
        {:ok, %{
          user_id: response.id
        }}
      {:error, error} ->
        IO.write("error: " <> inspect(error.metadata.resp_body["message"]))
        {:error, error.metadata.resp_body["message"] || "Signup failed"}
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

  @doc """
  Sends a magic link to the provided email.
  """
  @spec send_magic_link(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def send_magic_link(email) do
    # Get the GoTrue module (real or mocked)
    gotrue = Application.get_env(:pantheon, :gotrue_module, Supabase.GoTrue)
    client = Application.get_env(:pantheon, :supabase_client, Client)

    params = %{email: email}

    case gotrue.send_magic_link(client, params) do
      {:ok, response} ->
        {:ok, response["message"] || "Magic link sent"}
      {:error, error} ->
        {:error, error["message"] || "Failed to send magic link"}
    end
  end

  @doc """
  Verifies a JWT token from Supabase.
  Returns {:ok, user_data} if valid, {:error, reason} otherwise.
  """
  @spec verify_token(String.t()) :: {:ok, map()} | {:error, atom()}
  def verify_token(token) do
    # Get the GoTrue module (real or mocked)
    gotrue = Application.get_env(:pantheon, :gotrue_module, Supabase.GoTrue)
    client = Application.get_env(:pantheon, :supabase_client, Client)

    session = %Supabase.GoTrue.Session{access_token: token}

    case gotrue.get_user(client, session) do
      {:ok, user_data} ->
        {:ok, user_data}
      {:error, %{"message" => "Token expired"}} ->
        {:error, :token_expired}
      {:error, _} ->
        {:error, :invalid_token}
    end
  end
end
