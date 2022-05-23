defmodule AdvancedCounterRelay.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      AdvancedCounterRelay.Telemetry,
      # Start the Endpoint (http/https)
      AdvancedCounterRelay.Endpoint
      # Start a worker by calling: AdvancedCounterRelay.Worker.start_link(arg)
      # {AdvancedCounterRelay.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AdvancedCounterRelay.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AdvancedCounterRelay.Endpoint.config_change(changed, removed)
    :ok
  end
end
