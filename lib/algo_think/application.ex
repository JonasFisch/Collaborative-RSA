defmodule AlgoThink.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      AlgoThinkWeb.Telemetry,
      # Start the Ecto repository
      AlgoThink.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: AlgoThink.PubSub},
      # Start Finch
      {Finch, name: AlgoThink.Finch},
      # Start the Endpoint (http/https)
      AlgoThinkWeb.Endpoint
      # Start a worker by calling: AlgoThink.Worker.start_link(arg)
      # {AlgoThink.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AlgoThink.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AlgoThinkWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
