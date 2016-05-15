defmodule CloudControlServer.ServiceHandler do
	use GenServer

	## interface

	def start_link service_config do
		GenServer.start_link __MODULE__, service_config
	end

  def get_config handler do
    GenServer.call handler, {:get_config}
  end

	## callbacks

	def init service_config do
		state = %{ service_config: service_config }

		{:ok, state}
	end

	def handle_call {:get_config}, _caller, state do
		{:reply, Map.get(state, :service_config), state}
	end
end
