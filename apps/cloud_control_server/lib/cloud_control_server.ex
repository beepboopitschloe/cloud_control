defmodule CloudControlServer do
  use Application

  alias CloudControlServer.ServiceRegistry

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(ServiceRegistry, [[name: :service_registry]])
    ]

    opts = [strategy: :one_for_one, name: CloudControlServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
