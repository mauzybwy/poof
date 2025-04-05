defmodule Poof.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PoofWeb.Telemetry,
      Poof.Repo,
      {DNSCluster, query: Application.get_env(:poof, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Poof.PubSub},
      # Start a worker by calling: Poof.Worker.start_link(arg)
      # {Poof.Worker, arg},
      # Start to serve requests, typically the last entry
      PoofWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Poof.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PoofWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
