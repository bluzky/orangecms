defmodule OrangeCms.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      OrangeCmsWeb.Telemetry,
      # Start the Ecto repository
      OrangeCms.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: OrangeCms.PubSub},
      # Start Finch
      {Finch, name: OrangeCms.Finch},
      # Start the Endpoint (http/https)
      OrangeCmsWeb.Endpoint,
      {AshAuthentication.Supervisor, otp_app: :orange_cms}
      # Start a worker by calling: OrangeCms.Worker.start_link(arg)
      # {OrangeCms.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: OrangeCms.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    OrangeCmsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
