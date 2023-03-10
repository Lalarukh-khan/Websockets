defmodule SatoriPubsub.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      SatoriPubsub.Repo,
      # Start the Telemetry supervisor
      SatoriPubsubWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: SatoriPubsub.PubSub},
      SatoriPubsub.PgListener,
      # Start the Endpoint (http/https)
      SatoriPubsubWeb.Endpoint
      # Start a worker by calling: SatoriPubsub.Worker.start_link(arg)
      # {SatoriPubsub.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SatoriPubsub.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SatoriPubsubWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
