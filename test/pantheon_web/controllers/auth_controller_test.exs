defmodule PantheonWeb.AuthControllerTest do
  use PantheonWeb.ConnCase

  alias Pantheon.Auth.AuthService

  setup %{conn: conn} do
    # Store original module
    original_auth_service = Application.get_env(:pantheon, :auth_service, AuthService)

    on_exit(fn ->
      # Restore original module
      Application.put_env(:pantheon, :auth_service, original_auth_service)
    end)

    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "register/2" do
    test "returns token when registration succeeds", %{conn: conn} do
      # Mock the auth service
      mock_service = fn ->
        defmodule MockRegisterService do
          def sign_up("test@example.com", "password123") do
            {:ok, %{token: "mock_token", user_id: "user-123"}}
          end

          def sign_up(_, _) do
            {:error, :email_required}  # Match existing FallbackController error
          end
        end

        MockRegisterService
      end.()

      Application.put_env(:pantheon, :auth_service, mock_service)

      conn = post(conn, ~p"/api/auth/register", %{
        email: "test@example.com",
        password: "password123"
      })

      assert %{"token" => "mock_token", "user_id" => "user-123"} = json_response(conn, 201)["data"]
    end

    test "returns error when registration fails", %{conn: conn} do
      # Mock the auth service
      mock_service = fn ->
        defmodule MockFailRegisterService do
          def sign_up(_, _) do
            {:error, :email_required}  # Match existing FallbackController error
          end
        end

        MockFailRegisterService
      end.()

      Application.put_env(:pantheon, :auth_service, mock_service)

      conn = post(conn, ~p"/api/auth/register", %{
        email: "test@example.com",
        password: "wrong"
      })

      assert json_response(conn, 422)["errors"] != %{}
      assert json_response(conn, 422)["errors"]["detail"] == "Email is required"
    end
  end
end
