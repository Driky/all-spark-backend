defmodule AllsparkWeb.AuthController do
  use AllsparkWeb, :controller

  alias Allspark.Auth.AuthService

  action_fallback AllsparkWeb.FallbackController

  def register(conn, %{"email" => email, "password" => password}) do
    auth_service = Application.get_env(:allspark, :auth_service, AuthService)

    with {:ok, result} <- auth_service.sign_up(email, password) do
      conn
      |> put_status(:created)
      |> render(:user_id, data: result)
    end
  end

  def login(conn, %{"email" => email, "password" => password}) do
    auth_service = Application.get_env(:allspark, :auth_service, AuthService)

    with {:ok, result} <- auth_service.sign_in(email, password) do
      conn
      |> render(:token, data: result)
    end
  end

  def magic_link(conn, %{"email" => email}) do
    auth_service = Application.get_env(:allspark, :auth_service, AuthService)

    with {:ok, message} <- auth_service.send_magic_link(email) do
      conn
      |> render(:message, data: %{message: message})
    end
  end
end
