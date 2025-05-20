defmodule PantheonWeb.AuthPlugTest do
  use PantheonWeb.ConnCase, async: true

  alias PantheonWeb.AuthPlug
  alias Pantheon.Auth.{AuthService, User}

  # Create a mock module for testing
  defmodule MockAuthService do
    def verify_token("valid_token") do
      {:ok, %{
        "id" => "user-123",
        "email" => "test@example.com",
        "user_metadata" => %{
          "full_name" => "Test User",
          "role" => "nutritionist"
        }
      }}
    end

    def verify_token("expired_token") do
      {:error, :token_expired}
    end

    def verify_token(_) do
      {:error, :invalid_token}
    end
  end

  setup %{conn: conn} do
    # Store original module
    original_auth_service = Application.get_env(:pantheon, :auth_service, AuthService)

    # Set up mock module
    Application.put_env(:pantheon, :auth_service, MockAuthService)

    on_exit(fn ->
      # Restore original module
      Application.put_env(:pantheon, :auth_service, original_auth_service)
    end)

    {:ok, conn: conn}
  end

  describe "call/2 with valid token" do
    test "adds current_user to conn", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer valid_token")
        |> AuthPlug.call([])

      assert %User{} = conn.assigns.current_user
      assert conn.assigns.current_user.id == "user-123"
      assert conn.assigns.current_user.email == "test@example.com"
      refute conn.halted
    end
  end

  describe "call/2 with invalid token" do
    test "halts the connection with 401 status", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer invalid_token")
        |> AuthPlug.call([])

      assert conn.halted
      assert conn.status == 401
      assert Jason.decode!(conn.resp_body) == %{"errors" => %{"detail" => "Invalid token", "status" => 401}}
    end
  end

  describe "call/2 with expired token" do
    test "halts the connection with 401 status and specific message", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer expired_token")
        |> AuthPlug.call([])

      assert conn.halted
      assert conn.status == 401
      assert Jason.decode!(conn.resp_body) == %{"errors" => %{"detail" => "Token expired", "status" => 401}}
    end
  end

  describe "call/2 with missing token" do
    test "halts the connection with 401 status", %{conn: conn} do
      conn = AuthPlug.call(conn, [])

      assert conn.halted
      assert conn.status == 401
      assert Jason.decode!(conn.resp_body) == %{"errors" => %{"detail" => "Missing authorization token", "status" => 401}}
    end
  end
end
