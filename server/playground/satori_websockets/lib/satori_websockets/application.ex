defmodule SatoriWebsockets.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # %{
      # id: Phoenix.PubSub,
      # start: {SatoriWebsockets.List, :start_link, [:index, []]}
      # },
      # %{
      #   id: Phoenix.PubSub, start: {SatoriWebsockets.List, :start_link, [:index, []]}
      # },
      # Start the Telemetry supervisor
      SatoriWebsocketsWeb.Telemetry,

      {Phoenix.PubSub, name: SatoriWebsockets.PubSub},
      # SatoriWebsockets.PgListener,
      SatoriWebsockets.PubsubServer,
      # %{id: SatoriWebsockets.PgListener, start: {SatoriWebsockets.PubSub, :start_link, [:index, []]}},
      # %{id: SatoriWebsockets.PgListener, start: {SatoriWebsockets.PgListener, :start_link, [:index, []]}},
      # Start the PubSub system
      # {Phoenix.PubSub, name: SatoriWebsockets.PubSub},
      # Start the Endpoint (http/https)
      SatoriWebsocketsWeb.Endpoint
      # Start a worker by calling: SatoriWebsockets.Worker.start_link(arg)
      # {SatoriWebsockets.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SatoriWebsockets.Supervisor]
    Supervisor.start_link(children, opts)
  end
  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SatoriWebsocketsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
