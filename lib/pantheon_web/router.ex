defmodule PantheonWeb.Router do
  use PantheonWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PantheonWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug :accepts, ["json"]
    plug PantheonWeb.AuthPlug
  end

  scope "/", PantheonWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Public API endpoints (no auth required)
  scope "/api/auth", PantheonWeb do
    pipe_through :api

    post "/register", AuthController, :register
    post "/login", AuthController, :login
    post "/magic-link", AuthController, :magic_link
  end

  # Protected API endpoints (auth required)
  scope "/api", PantheonWeb do
    pipe_through [:api, :auth]

    resources "/patients", PatientController, except: [:new, :edit, :delete]
    get "/nutritionists/:nutritionist_id/patients", PatientController, :list_by_nutritionist
  end

end
