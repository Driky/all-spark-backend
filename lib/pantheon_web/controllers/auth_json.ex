defmodule AllsparkWeb.AuthJSON do
  @moduledoc """
  JSON view for auth responses.
  """

  @doc """
  Renders token data.
  """
  def user_id(%{data: data}) do
    %{data: %{
      user_id: data.user_id
    }}
  end

  @doc """
  Renders token data.
  """
  def token(%{data: data}) do
    %{data: %{
      token: data.token,
      user_id: data.user_id
    }}
  end

  @doc """
  Renders message data.
  """
  def message(%{data: data}) do
    %{data: %{
      message: data.message
    }}
  end
end
