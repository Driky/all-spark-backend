defmodule Pantheon.Auth.UserTest do
  use ExUnit.Case, async: true

  alias Pantheon.Auth.User

  describe "from_supabase/1" do
    test "creates a user struct from Supabase user data" do
      supabase_data = %{
        "id" => "user-123",
        "email" => "test@example.com",
        "user_metadata" => %{
          "full_name" => "Test User",
          "role" => "nutritionist"
        }
      }

      user = User.from_supabase(supabase_data)

      assert user.id == "user-123"
      assert user.email == "test@example.com"
      assert user.full_name == "Test User"
      assert user.role == "nutritionist"
    end

    test "handles missing metadata" do
      supabase_data = %{
        "id" => "user-123",
        "email" => "test@example.com"
      }

      user = User.from_supabase(supabase_data)

      assert user.id == "user-123"
      assert user.email == "test@example.com"
      assert user.full_name == nil
      assert user.role == nil
      assert user.metadata == %{}
    end

    test "handles JWT data format with sub instead of id" do
      jwt_data = %{
        "sub" => "user-123",
        "email" => "test@example.com",
        "user_metadata" => %{
          "full_name" => "Test User",
          "role" => "nutritionist"
        }
      }

      user = User.from_supabase(jwt_data)

      assert user.id == "user-123"
      assert user.email == "test@example.com"
    end
  end
end
