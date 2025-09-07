defmodule AllsparkWeb.ErrorJSONTest do
  use AllsparkWeb.ConnCase, async: true

  test "renders 404" do
    assert AllsparkWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert AllsparkWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end

  test "error.json renders error message" do
    assert AllsparkWeb.ErrorJSON.error(%{status: :not_found, message: "Resource not found"}) ==
      %{errors: %{detail: "Resource not found", status: 404}}

    assert AllsparkWeb.ErrorJSON.error(%{status: :unprocessable_entity, message: "Invalid data"}) ==
      %{errors: %{detail: "Invalid data", status: 422}}
  end
end
