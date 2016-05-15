defmodule CloudControlServer.ServiceRegistry do
	use GenServer

	alias CloudControlServer.ServiceHandler

	## interface

	def start_link opts \\ [] do
		GenServer.start_link(__MODULE__, nil, opts)
	end

	def start_handler registry, service_config do
		GenServer.call registry, {:start_handler, service_config}
	end

  def find_all_handlers registry do
    GenServer.call registry, {:find_all_handlers}
  end

  def find_handlers_by_config registry, config do
    GenServer.call registry, {:find_handlers_by_config, config}
  end

	## callbacks

	def init nil do
    # TODO use a map here, keys should be node UUIDs
		state = %{ handlers: [] }

		{:ok, state}
	end

	def handle_call {:start_handler, service_config}, _caller, state do
		{:ok, handler} = ServiceHandler.start_link service_config

		%{ handlers: handlers } = state

		state = %{ state |
							 handlers: List.insert_at(handlers, 0, handler)}

		{:reply, {:ok, handler}, state}
	end

  def handle_call {:find_all_handlers}, _caller, %{ handlers: handlers } = state do
    {:reply, {:ok, handlers}, state}
  end

  def handle_call {:find_handlers_by_config, config}, _caller, %{ handlers: handlers } = state do
    filtered = Enum.filter handlers, fn(h) ->
      h_config = ServiceHandler.get_config h

      h_config == config
    end

    {:reply, {:ok, filtered}, state}
  end
end
