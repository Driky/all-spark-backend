defmodule PantheonWeb.AuthJSONTest do
  use PantheonWeb.ConnCase, async: true

  alias PantheonWeb.AuthJSON

  test "token/1 renders token data" do
    token_data = %{
      token: "mock_token",
      user_id: "user-123"
    }

    rendered = AuthJSON.token(%{data: token_data})

    assert rendered == %{
      data: %{
        token: "mock_token",
        user_id: "user-123"
      }
    }
  end

  test "message/1 renders message data" do
    message_data = %{
      message: "Magic link sent"
    }

    rendered = AuthJSON.message(%{data: message_data})

    assert rendered == %{
      data: %{
        message: "Magic link sent"
      }
    }
  end
end
