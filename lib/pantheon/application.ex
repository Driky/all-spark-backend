defmodule Pantheon.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc """
  Pantheon application module responsible for starting the application's supervision tree.
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PantheonWeb.Telemetry,
      Pantheon.Repo,
      {DNSCluster, query: Application.get_env(:pantheon, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Pantheon.PubSub},
      # Pantheon.EventStore,
      Pantheon.CommandedApplication,
      # Start a worker by calling: Pantheon.Worker.start_link(arg)
      # {Pantheon.Worker, arg},
      # Start to serve requests, typically the last entry
      PantheonWeb.Endpoint,
      Pantheon.Supabase.Client
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Pantheon.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PantheonWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
