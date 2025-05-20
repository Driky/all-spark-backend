defmodule Pantheon.Auth.AuthServiceTest do
  use ExUnit.Case

  alias Pantheon.Auth.AuthService

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
  end

  setup do
    # Store original modules
    original_client = Application.get_env(:pantheon, :supabase_client, Pantheon.Supabase.Client)
    original_gotrue = Application.get_env(:pantheon, :gotrue_module, Supabase.GoTrue)

    # Set up mock modules
    Application.put_env(:pantheon, :gotrue_module, MockGoTrue)

    on_exit(fn ->
      # Restore original modules
      Application.put_env(:pantheon, :supabase_client, original_client)
      Application.put_env(:pantheon, :gotrue_module, original_gotrue)
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
end
