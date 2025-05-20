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
            {:ok, %{user_id: "user-123"}}
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

      Application.put_env(:pantheon, :auth_service, mock_service)

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

      Application.put_env(:pantheon, :auth_service, mock_service)

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

      Application.put_env(:pantheon, :auth_service, mock_service)

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

      Application.put_env(:pantheon, :auth_service, mock_service)

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

  #     Application.put_env(:pantheon, :auth_service, mock_service)

  #     conn = post(conn, ~p"/api/auth/magic-link", %{
  #       email: "wrong@example.com"
  #     })

  #     assert json_response(conn, 422)["errors"] != %{}
  #     assert json_response(conn, 422)["errors"]["detail"] == "Email is required"
  #   end
  end
end
