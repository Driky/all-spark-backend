defmodule Allspark.Auth.AuthServiceTest do
  use ExUnit.Case

  alias Allspark.Auth.AuthService

  # Create a mock module for testing
  defmodule MockGoTrue do
    def sign_up(_, %{email: "test@example.com", password: "password123"}) do
      {:ok, %{id: "user-123"}}
    end

    def sign_up(_, _) do
      {:error, %{metadata: %{resp_body: %{"message" => "Invalid signup"}}}}
    end

    def sign_in_with_password(_, %{email: "test@example.com", password: "password123"}) do
      {:ok, %{
        access_token: "mock_token",
        user: %{
          id: "user-123",
          email: "test@example.com"
        }
      }}
    end

    def sign_in_with_password(_, _) do
      {:error, %{metadata: %{resp_body: %{"msg" => "Invalid login credentials"}}}}
    end

    def send_magic_link(_, %{email: "test@example.com"}) do
      {:ok, %{"message" => "Magic link sent"}}
    end

    def send_magic_link(_, _) do
      {:error, %{"message" => "Failed to send magic link"}}
    end

    def resend(_client, "test@example.com", %{type: :signup, options: %{email_redirect_to: _}}) do
      :ok
    end

    def resend(_client, _, _) do
      {:error, %{metadata: %{resp_body: %{"message" => "Failed to resend verification email"}}}}
    end

    def get_user(_client, %{access_token: "valid_token"}) do
      {:ok, %{
        "id" => "user-123",
        "email" => "test@example.com",
        "user_metadata" => %{
          "full_name" => "Test User",
          "role" => "nutritionist"
        }
      }}
    end

    def get_user(_client, %{access_token: "expired_token"}) do
      {:error, %{"message" => "Token expired"}}
    end

    def get_user(_, _) do
      {:error, %{"message" => "Invalid token"}}
    end

    # Mock sign_out matching real Supabase behavior
    # Real implementation returns :ok for success, unauthorized, and not_found
    def sign_out(_client, %{access_token: "valid_token"}, :local) do
      :ok
    end

    def sign_out(_client, %{access_token: "unauthorized_token"}, :local) do
      :ok  # Real Supabase returns :ok for unauthorized
    end

    def sign_out(_client, %{access_token: "not_found_token"}, :local) do
      :ok  # Real Supabase returns :ok for not_found
    end

    def sign_out(_client, %{access_token: "server_error_token"}, :local) do
      {:error, %{message: "Internal server error"}}
    end

    def sign_out(_, _, _) do
      :ok
    end
  end

  setup do
    # Store original modules
    original_client = Application.get_env(:allspark, :supabase_client, Allspark.Supabase.Client)
    original_gotrue = Application.get_env(:allspark, :gotrue_module, Supabase.GoTrue)

    # Set up mock modules
    Application.put_env(:allspark, :gotrue_module, MockGoTrue)

    on_exit(fn ->
      # Restore original modules
      Application.put_env(:allspark, :supabase_client, original_client)
      Application.put_env(:allspark, :gotrue_module, original_gotrue)
    end)

    :ok
  end

  describe "verify_token/1" do
    test "returns user data with valid token" do
      assert {:ok, user_data} = AuthService.verify_token("valid_token")
      assert user_data["id"] == "user-123"
      assert user_data["email"] == "test@example.com"
    end

    test "returns token_expired error when token is expired" do
      assert {:error, :token_expired} = AuthService.verify_token("expired_token")
    end

    test "returns invalid_token error for other errors" do
      assert {:error, :invalid_token} = AuthService.verify_token("invalid_token")
    end
  end

  describe "send_magic_link/1" do
    test "returns success message when sending magic link" do
      assert {:ok, "Magic link sent"} =
        AuthService.send_magic_link("test@example.com")
    end

    test "returns error when magic link fails" do
      assert {:error, "Failed to send magic link"} =
        AuthService.send_magic_link("invalid@example.com")
    end
  end

  describe "sign_in/2" do
    test "returns ok with valid credentials" do
      assert {:ok, %{token: "mock_token", user_id: "user-123"}} =
        AuthService.sign_in("test@example.com", "password123")
    end

    test "returns error with invalid credentials" do
      assert {:error, "Invalid login credentials"} =
        AuthService.sign_in("test@example.com", "wrong")
    end
  end

  describe "sign_up/2" do
    test "returns ok with valid credentials" do
      assert {:ok, %{user_id: "user-123"}} =
        AuthService.sign_up("test@example.com", "password123")
    end

    test "returns error with invalid input" do
      assert {:error, "Invalid signup"} =
        AuthService.sign_up("wrong@example.com", "wrong")
    end
  end

  describe "sign_out/1" do
    test "returns ok when sign out succeeds with valid token" do
      assert {:ok, "Successfully signed out"} =
        AuthService.sign_out("valid_token")
    end

    test "returns ok when token is unauthorized (Supabase returns :ok)" do
      assert {:ok, "Successfully signed out"} =
        AuthService.sign_out("unauthorized_token")
    end

    test "returns ok when token is not found (Supabase returns :ok)" do
      assert {:ok, "Successfully signed out"} =
        AuthService.sign_out("not_found_token")
    end

    test "returns error when server error occurs" do
      assert {:error, "Internal server error"} =
        AuthService.sign_out("server_error_token")
    end
  end

  describe "resend_verification_email/1" do
    test "returns success message when resending verification email" do
      assert {:ok, "Verification email resent"} =
        AuthService.resend_verification_email("test@example.com")
    end

    test "returns error when resend fails" do
      assert {:error, "Failed to resend verification email"} =
        AuthService.resend_verification_email("invalid@example.com")
    end
  end
end
