defmodule PantheonWeb.AuthPlugTest do
  use PantheonWeb.ConnCase, async: true

  alias PantheonWeb.AuthPlug
  alias Pantheon.Auth.User

  # Mock tokens that we'll use in tests
  @valid_token "valid.mock.token"
  @invalid_token "invalid.token"
  @expired_token "expired.token"

  setup %{conn: conn} do
    # Mock the verify_token function
    verify_token_fn = fn token ->
      case token do
        @valid_token ->
          {:ok, %{
            "id" => "user-123",
            "email" => "test@example.com",
            "user_metadata" => %{
              "full_name" => "Test User",
              "role" => "nutritionist"
            }
          }}
        @expired_token ->
          {:error, :token_expired}
        @invalid_token ->
          {:error, :invalid_token}
        _ ->
          {:error, :invalid_token}
      end
    end

    # Configure the application to use our mock
    original_fn = Application.get_env(:pantheon, :verify_token_function)
    Application.put_env(:pantheon, :verify_token_function, verify_token_fn)

    on_exit(fn ->
      Application.put_env(:pantheon, :verify_token_function, original_fn)
    end)

    {:ok, conn: conn}
  end

  describe "call/2 with valid token" do
    test "adds current_user to conn", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{@valid_token}")
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
        |> put_req_header("authorization", "Bearer #{@invalid_token}")
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
        |> put_req_header("authorization", "Bearer #{@expired_token}")
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
