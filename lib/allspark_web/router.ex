defmodule AllsparkWeb.Router do
  use AllsparkWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AllsparkWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug :accepts, ["json"]
    plug AllsparkWeb.AuthPlug
  end

  scope "/", AllsparkWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Public API endpoints (no auth required)
  scope "/api/auth", AllsparkWeb do
    pipe_through :api

    post "/register", AuthController, :register
    post "/login", AuthController, :login
    post "/magic-link", AuthController, :magic_link
    post "/resend-verification", AuthController, :resend_verification
  end

  # Protected API endpoints (auth required)
  scope "/api", AllsparkWeb do
    pipe_through [:api, :auth]

    post "/auth/logout", AuthController, :logout
    #resources "/patients", PatientController, except: [:new, :edit, :delete]
    #get "/nutritionists/:nutritionist_id/patients", PatientController, :list_by_nutritionist
  end

end
