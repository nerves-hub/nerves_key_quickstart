defmodule NervesKeyQuickstartPhx.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      NervesKeyQuickstartPhxWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: NervesKeyQuickstartPhx.PubSub},
      # Start the Endpoint (http/https)
      NervesKeyQuickstartPhxWeb.Endpoint
      # Start a worker by calling: NervesKeyQuickstartPhx.Worker.start_link(arg)
      # {NervesKeyQuickstartPhx.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: NervesKeyQuickstartPhx.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    NervesKeyQuickstartPhxWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
