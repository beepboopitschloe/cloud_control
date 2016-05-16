defmodule CloudControlClient do
  use Application

  alias CloudControlClient.ConnectionHandler

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(ConnectionHandler, [])
    ]

    opts = [strategy: :one_for_one, name: CloudControlClient.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
