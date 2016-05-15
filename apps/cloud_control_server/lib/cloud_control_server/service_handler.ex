defmodule CloudControlServer.ServiceHandler do
  use GenServer

  @status_not_started :not_started
  @status_starting :starting
  @status_error :error

  @ping_interval 30_000

  alias CloudControlServer.DigitalOceanClient

  ## interface

  def start_link service_config do
    GenServer.start_link __MODULE__, service_config
  end

  def get_config handler do
    GenServer.call handler, {:get_config}
  end

  def get_status handler do
    GenServer.call handler, {:get_status}
  end

  ## callbacks

  def init %{ node_name: _node_name } = service_config do
    state = %{ service_config: service_config,
               status: {@status_not_started} }

    GenServer.cast self, {:create_node}

    {:ok, state}
  end

  def handle_call {:get_config}, _caller, state do
    {:reply, Map.get(state, :service_config), state}
  end

  def handle_call {:get_status}, _caller, %{ status: status } = state do
    {:reply, status, state}
  end

  def handle_cast {:create_node}, %{ service_config: config } = state do
    %{ node_name: node_name } = config

    case DigitalOceanClient.create_droplet node_name do
      {:ok, _response} ->
        state = %{ state |
                   status: {@status_starting}}
        schedule_ping
      {:error, reason} ->
        state = %{ state |
                   status: {@status_error, reason} }
    end

    {:noreply, state}
  end

  def handle_info {:do_ping}, state do
    IO.puts "ping"

    schedule_ping

    {:noreply, state}
  end

  ## private methods

  defp schedule_ping do
    Process.send_after self, {:do_ping}, @ping_interval
  end
end
