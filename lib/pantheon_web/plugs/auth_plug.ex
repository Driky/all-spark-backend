defmodule PantheonWeb.AuthPlug do
  @moduledoc """
  Plug for authenticating requests using Supabase JWT tokens.
  """
  import Plug.Conn

  alias Pantheon.Auth.{AuthService, User}

  def init(opts), do: opts

  def call(conn, _opts) do
    with {:ok, token} <- get_token(conn),
         {:ok, user_data} <- verify_token(token),
         {:ok, user} <- create_user(user_data) do
      assign(conn, :current_user, user)
    else
      _ ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(401, Jason.encode!(%{
            errors: %{
              detail: "Unauthorized",
              status: 401
            }
          }))
        |> halt()
    end
  end

  defp get_token(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] -> {:ok, token}
      _ -> {:error, :missing_token}
    end
  end

  defp verify_token(token) do
    auth_service = Application.get_env(:pantheon, :auth_service, AuthService)
    auth_service.verify_token(token)
  end

  defp create_user(user_data) do
    {:ok, User.from_supabase(user_data)}
  end
end
