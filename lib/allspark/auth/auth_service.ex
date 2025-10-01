defmodule Allspark.Auth.AuthService do
  @moduledoc """
  Handles authentication via Supabase.
  """

  alias Allspark.Supabase.Client

  @doc """
  Signs up a new user with email and password.
  """
  @spec sign_up(String.t(), String.t()) :: {:ok, map()} | {:error, String.t()}
  def sign_up(email, password) do
    # Get the GoTrue module (real or mocked)
    gotrue = Application.get_env(:allspark, :gotrue_module, Supabase.GoTrue)
    client_module = Application.get_env(:allspark, :supabase_client, Client)
    {:ok, client} = client_module.get_client()

    params = %{email: email, password: password}

    case gotrue.sign_up(client, params) do
      {:ok, response} ->
        {:ok,
         %{
           user_id: response.id
         }}

      {:error, error} ->
        {:error, error.metadata.resp_body["message"] || "Signup failed"}
    end
  end

  @doc """
  Signs in a user with email and password.
  """
  @spec sign_in(String.t(), String.t()) :: {:ok, map()} | {:error, String.t()}
  def sign_in(email, password) do
    # Get the GoTrue module (real or mocked)
    gotrue = Application.get_env(:allspark, :gotrue_module, Supabase.GoTrue)
    client_module = Application.get_env(:allspark, :supabase_client, Client)
    {:ok, client} = client_module.get_client()

    params = %{email: email, password: password}

    case gotrue.sign_in_with_password(client, params) do
      {:ok, response} ->
        {:ok,
         %{
           token: response.access_token,
           user_id: response.user.id
         }}

      {:error, error} ->
        {:error, error.metadata.resp_body["msg"] || "Invalid credentials"}
    end
  end

  @doc """
  Sends a magic link to the provided email.
  """
  @spec send_magic_link(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def send_magic_link(email) do
    # Get the GoTrue module (real or mocked)
    gotrue = Application.get_env(:allspark, :gotrue_module, Supabase.GoTrue)
    client_module = Application.get_env(:allspark, :supabase_client, Client)
    {:ok, client} = client_module.get_client()

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
    gotrue = Application.get_env(:allspark, :gotrue_module, Supabase.GoTrue)
    client_module = Application.get_env(:allspark, :supabase_client, Client)
    {:ok, client} = client_module.get_client()

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

  @doc """
  Signs out a user with a JWT token.
  Returns {:ok, message} if successful or already logged out.
  Returns {:error, reason} for actual server/network errors.
  """
  @spec sign_out(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def sign_out(token) do
    # Get the GoTrue module (real or mocked)
    gotrue = Application.get_env(:allspark, :gotrue_module, Supabase.GoTrue)
    client_module = Application.get_env(:allspark, :supabase_client, Client)
    {:ok, client} = client_module.get_client()

    session = %Supabase.GoTrue.Session{access_token: token}

    # Note: Supabase.GoTrue.Admin.sign_out already returns :ok for unauthorized/not_found
    case gotrue.sign_out(client, session, :local) do
      :ok ->
        {:ok, "Successfully signed out"}

      {:error, %{message: message}} ->
        {:error, message}

      {:error, error} ->
        {:error, "Sign out failed: #{inspect(error)}"}
    end
  end

  @doc """
  Resends a verification email to the provided email address.
  """
  @spec resend_verification_email(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def resend_verification_email(email) do
    # Get the GoTrue module (real or mocked)
    gotrue = Application.get_env(:allspark, :gotrue_module, Supabase.GoTrue)
    client_module = Application.get_env(:allspark, :supabase_client, Client)
    {:ok, client} = client_module.get_client()

    # Get email_redirect_to from config (fail if not configured)
    email_redirect_to = Application.fetch_env!(:allspark, :email_redirect_to)

    # Structure params according to Supabase.GoTrue.Schemas.ResendParams
    params = %{
      type: :signup,
      email_redirect_to: email_redirect_to
    }

    case gotrue.resend(client, email, params) do
      :ok ->
        {:ok, "Verification email resent"}

      {:error, error} ->
        {:error, error.metadata.resp_body["message"] || "Failed to resend verification email"}
    end
  end
end
