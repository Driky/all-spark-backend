defmodule Pantheon.Auth.AuthServiceTest do
  use ExUnit.Case

  alias Pantheon.Auth.AuthService

  # Create a mock module for testing
  defmodule MockGoTrue do
    def sign_up_with_password(_, %{email: "test@example.com", password: "password123"}) do
      {:ok, %{
        "access_token" => "mock_token",
        "user" => %{
          "id" => "user-123",
          "email" => "test@example.com"
        }
      }}
    end

    def sign_up_with_password(_, _) do
      {:error, %{"message" => "Invalid signup"}}
    end

    def sign_in_with_password(_, %{email: "test@example.com", password: "password123"}) do
      {:ok, %{
        "access_token" => "mock_token",
        "user" => %{
          "id" => "user-123",
          "email" => "test@example.com"
        }
      }}
    end

    def sign_in_with_password(_, _) do
      {:error, %{"message" => "Invalid credentials"}}
    end
  end

  # Add to the existing test module:
  describe "sign_in/2" do
    test "returns ok with valid credentials" do
      assert {:ok, %{token: "mock_token", user_id: "user-123"}} =
        AuthService.sign_in("test@example.com", "password123")
    end

    test "returns error with invalid credentials" do
      assert {:error, "Invalid credentials"} =
        AuthService.sign_in("test@example.com", "wrong")
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

  describe "sign_up/2" do
    test "returns ok with valid credentials" do
      assert {:ok, %{token: "mock_token", user_id: "user-123"}} =
        AuthService.sign_up("test@example.com", "password123")
    end

    test "returns error with invalid input" do
      assert {:error, "Invalid signup"} =
        AuthService.sign_up("wrong@example.com", "wrong")
    end
  end
end
