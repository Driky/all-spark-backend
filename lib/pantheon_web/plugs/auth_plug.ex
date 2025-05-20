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
      {:error, :missing_token} ->
        conn
        |> send_error_resp(401, "Missing authorization token")

      {:error, :invalid_token} ->
        conn
        |> send_error_resp(401, "Invalid token")

      {:error, :token_expired} ->
        conn
        |> send_error_resp(401, "Token expired")

      _ ->
        conn
        |> send_error_resp(401, "Unauthorized")
    end
  end

  defp get_token(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] -> {:ok, token}
      _ -> {:error, :missing_token}
    end
  end

  defp verify_token(token) do
    verify_fn = Application.get_env(:pantheon, :verify_token_function, &AuthService.verify_token/1)
    verify_fn.(token)
  end

  defp create_user(user_data) do
    {:ok, User.from_supabase(user_data)}
  end

  defp send_error_resp(conn, status, message) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(%{
        errors: %{
          detail: message,
          status: status
        }
      }))
    |> halt()
  end
end
