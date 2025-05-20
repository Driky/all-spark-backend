defmodule PantheonWeb.FallbackController do
  @moduledoc """
  Translates controller action results into responses.
  Provides centralized error handling.
  """
  use PantheonWeb, :controller

  # Resource not found
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(json: PantheonWeb.ErrorJSON)
    |> render(:error, status: :not_found, message: "Resource not found")
  end

  # Invalid patient data
  def call(conn, {:error, :invalid_patient_data}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: PantheonWeb.ErrorJSON)
    |> render(:error, status: :unprocessable_entity, message: "Invalid patient data")
  end

  # Invalid patient ID
  def call(conn, {:error, :invalid_patient_id}) do
    conn
    |> put_status(:bad_request)
    |> put_view(json: PantheonWeb.ErrorJSON)
    |> render(:error, status: :bad_request, message: "Invalid patient ID format")
  end

  # Email required
  def call(conn, {:error, :email_required}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: PantheonWeb.ErrorJSON)
    |> render(:error, status: :unprocessable_entity, message: "Email is required")
  end

  # Invalid login credentials
  def call(conn, {:error, "Invalid login credentials"}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(json: PantheonWeb.ErrorJSON)
    |> render(:error, status: :unauthorized, message: "Invalid login credentials")
  end

  # Fallback for all other errors
  def call(conn, {:error, _reason}) do
    conn
    |> put_status(:internal_server_error)
    |> put_view(json: PantheonWeb.ErrorJSON)
    |> render(:error, status: :internal_server_error, message: "An unexpected error occurred")
  end
end
