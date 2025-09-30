defmodule AllsparkWeb.AuthControllerTest do
  use AllsparkWeb.ConnCase

  alias Allspark.Auth.AuthService

  setup %{conn: conn} do
    # Store original module
    original_auth_service = Application.get_env(:allspark, :auth_service, AuthService)

    on_exit(fn ->
      # Restore original module
      Application.put_env(:allspark, :auth_service, original_auth_service)
    end)

    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "register/2" do
    test "returns token when registration succeeds", %{conn: conn} do
      # Mock the auth service
      mock_service = fn ->
        defmodule MockRegisterService do
          def sign_up("test@example.com", "password123") do
            {:ok, %{user_id: "user-123"}}
          end

          def sign_up(_, _) do
            {:error, :email_required}  # Match existing FallbackController error
          end
        end

        MockRegisterService
      end.()

      Application.put_env(:allspark, :auth_service, mock_service)

      conn = post(conn, ~p"/api/auth/register", %{
        email: "test@example.com",
        password: "password123"
      })

      assert %{"user_id" => "user-123"} = json_response(conn, 201)["data"]
    end

    test "returns error when registration fails", %{conn: conn} do
      # Mock the auth service
      mock_service = fn ->
        defmodule MockFailRegisterService do
          def sign_up(_, _) do
            {:error, "Invalid login credentials"}  # Match existing FallbackController error
          end
        end

        MockFailRegisterService
      end.()

      Application.put_env(:allspark, :auth_service, mock_service)

      conn = post(conn, ~p"/api/auth/register", %{
        email: "test@example.com",
        password: "wrong"
      })

      assert json_response(conn, 401)["errors"] != %{}
      assert json_response(conn, 401)["errors"]["detail"] == "Invalid login credentials"
    end
  end

  describe "login/2" do
    test "returns token when login succeeds", %{conn: conn} do
      # Mock the auth service
      mock_service = fn ->
        defmodule MockLoginService do
          def sign_up(_, _), do: {:error, :not_found}  # Not used in this test

          def sign_in("test@example.com", "password123") do
            {:ok, %{token: "mock_token", user_id: "user-123"}}
          end

          def sign_in(_, _) do
            {:error, :not_found}  # Use an existing error type
          end
        end

        MockLoginService
      end.()

      Application.put_env(:allspark, :auth_service, mock_service)

      conn = post(conn, ~p"/api/auth/login", %{
        email: "test@example.com",
        password: "password123"
      })

      assert %{"token" => "mock_token", "user_id" => "user-123"} = json_response(conn, 200)["data"]
    end

    test "returns error when login fails", %{conn: conn} do
      # Mock the auth service
      mock_service = fn ->
        defmodule MockFailLoginService do
          def sign_up(_, _), do: {:error, :not_found}  # Not used in this test

          def sign_in(_, _) do
            {:error, :not_found}  # Use an existing error type
          end
        end

        MockFailLoginService
      end.()

      Application.put_env(:allspark, :auth_service, mock_service)

      conn = post(conn, ~p"/api/auth/login", %{
        email: "test@example.com",
        password: "wrong"
      })

      assert json_response(conn, 404)["errors"] != %{}
    end
  end

  describe "magic_link/2" do
    test "returns success when sending magic link", %{conn: conn} do
      # Mock the auth service
      mock_service = fn ->
        defmodule MockMagicLinkService do
          def sign_up(_, _), do: {:error, :not_found}  # Not used in this test
          def sign_in(_, _), do: {:error, :not_found}  # Not used in this test

          def send_magic_link("test@example.com") do
            {:ok, "Magic link sent"}
          end

          def send_magic_link(_) do
            {:error, :email_required}  # Use an existing error type
          end
        end

        MockMagicLinkService
      end.()

      Application.put_env(:allspark, :auth_service, mock_service)

      conn = post(conn, ~p"/api/auth/magic-link", %{
        email: "test@example.com"
      })

      assert %{"message" => "Magic link sent"} = json_response(conn, 200)["data"]
    end

  #   test "returns error when magic link fails", %{conn: conn} do
  #     # Mock the auth service
  #     mock_service = fn ->
  #       defmodule MockFailMagicLinkService do
  #         def sign_up(_, _), do: {:error, :not_found}  # Not used in this test
  #         def sign_in(_, _), do: {:error, :not_found}  # Not used in this test

  #         def send_magic_link(_) do
  #           {:error, :email_required}  # Use an existing error type
  #         end
  #       end

  #       MockFailMagicLinkService
  #     end.()

  #     Application.put_env(:allspark, :auth_service, mock_service)

  #     conn = post(conn, ~p"/api/auth/magic-link", %{
  #       email: "wrong@example.com"
  #     })

  #     assert json_response(conn, 422)["errors"] != %{}
  #     assert json_response(conn, 422)["errors"]["detail"] == "Email is required"
  #   end
  end

  describe "logout/2" do
    test "returns success when logout succeeds with valid token", %{conn: conn} do
      # Mock the auth service
      mock_service = fn ->
        defmodule MockLogoutService do
          def sign_up(_, _), do: {:error, :not_found}
          def sign_in(_, _), do: {:error, :not_found}

          def sign_out("valid_token") do
            {:ok, "Successfully signed out"}
          end

          def sign_out(_) do
            {:error, "Sign out failed"}
          end
        end

        MockLogoutService
      end.()

      Application.put_env(:allspark, :auth_service, mock_service)

      # Mock verify_token to allow AuthPlug to pass
      mock_verify = fn "valid_token" ->
        {:ok, %{
          "id" => "user-123",
          "email" => "test@example.com"
        }}
      end

      Application.put_env(:allspark, :verify_token_function, mock_verify)

      conn = conn
      |> put_req_header("authorization", "Bearer valid_token")
      |> post(~p"/api/auth/logout")

      assert %{"message" => "Successfully signed out"} = json_response(conn, 200)["data"]
    end

    test "returns error when logout fails with server error", %{conn: conn} do
      # Mock the auth service
      mock_service = fn ->
        defmodule MockLogoutErrorService do
          def sign_up(_, _), do: {:error, :not_found}
          def sign_in(_, _), do: {:error, :not_found}

          def sign_out(_) do
            {:error, "Internal server error"}
          end
        end

        MockLogoutErrorService
      end.()

      Application.put_env(:allspark, :auth_service, mock_service)

      # Mock verify_token to allow AuthPlug to pass
      mock_verify = fn "valid_token" ->
        {:ok, %{
          "id" => "user-123",
          "email" => "test@example.com"
        }}
      end

      Application.put_env(:allspark, :verify_token_function, mock_verify)

      conn = conn
      |> put_req_header("authorization", "Bearer valid_token")
      |> post(~p"/api/auth/logout")

      # Verify error response structure from FallbackController
      response = json_response(conn, 500)
      assert response["errors"] != %{}
      assert response["errors"]["detail"] == "An unexpected error occurred"
      assert response["errors"]["status"] == 500
    end

    test "returns 401 when no authorization token provided", %{conn: conn} do
      conn = post(conn, ~p"/api/auth/logout")

      assert json_response(conn, 401)["errors"]["detail"] == "Missing authorization token"
    end

    test "returns 401 when token is expired", %{conn: conn} do
      # Mock verify_token to reject expired token
      mock_verify = fn "expired_token" ->
        {:error, :token_expired}
      end

      Application.put_env(:allspark, :verify_token_function, mock_verify)

      conn = conn
      |> put_req_header("authorization", "Bearer expired_token")
      |> post(~p"/api/auth/logout")

      assert json_response(conn, 401)["errors"]["detail"] == "Token expired"
    end
  end
end
