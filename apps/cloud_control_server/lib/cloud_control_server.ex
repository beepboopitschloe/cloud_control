defmodule CloudControlServer do
  use Application

  alias CloudControlServer.ServiceRegistry

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(ServiceRegistry, [[name: :service_registry]])
    ]
  end
end
