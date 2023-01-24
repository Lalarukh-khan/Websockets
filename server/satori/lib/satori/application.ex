defmodule Satori.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Satori.Repo,
      # Start the Telemetry supervisor
      SatoriWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Satori.PubSub},
      # Start the Endpoint (http/https)
      SatoriWeb.Endpoint,
      {Absinthe.Subscription, SatoriWeb.Endpoint},
      Satori.PubSub.TopicInMemory
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Satori.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SatoriWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
