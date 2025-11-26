defmodule Allspark.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc """
  Allspark application module responsible for starting the application's supervision tree.
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AllsparkWeb.Telemetry,
      Allspark.Repo,
      FinancialAccounts.App,
      {Oban, Application.fetch_env!(:allspark, Oban)},
      {DNSCluster, query: Application.get_env(:allspark, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Allspark.PubSub},
      # Start a worker by calling: Allspark.Worker.start_link(arg)
      # {Allspark.Worker, arg},
      # Start to serve requests, typically the last entry
      AllsparkWeb.Endpoint,
      Allspark.Supabase.Client
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Allspark.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AllsparkWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
