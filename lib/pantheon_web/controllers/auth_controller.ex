defmodule PantheonWeb.AuthController do
  use PantheonWeb, :controller

  alias Pantheon.Auth.AuthService

  action_fallback PantheonWeb.FallbackController

  def register(conn, %{"email" => email, "password" => password}) do
    auth_service = Application.get_env(:pantheon, :auth_service, AuthService)

    with {:ok, result} <- auth_service.sign_up(email, password) do
      conn
      |> put_status(:created)
      |> render(:user_id, data: result)
    end
  end

  def login(conn, %{"email" => email, "password" => password}) do
    auth_service = Application.get_env(:pantheon, :auth_service, AuthService)

    with {:ok, result} <- auth_service.sign_in(email, password) do
      conn
      |> render(:token, data: result)
    end
  end

  def magic_link(conn, %{"email" => email}) do
    auth_service = Application.get_env(:pantheon, :auth_service, AuthService)

    with {:ok, message} <- auth_service.send_magic_link(email) do
      conn
      |> render(:message, data: %{message: message})
    end
  end
end
