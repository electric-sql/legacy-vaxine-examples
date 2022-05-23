defmodule AdvancedCounter.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      AdvancedCounter.Repos.CloudSql,
      # Start the PubSub system
      {Phoenix.PubSub, name: AdvancedCounter.PubSub}
      # Start a worker by calling: AdvancedCounter.Worker.start_link(arg)
      # {AdvancedCounter.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: AdvancedCounter.Supervisor)
  end
end
