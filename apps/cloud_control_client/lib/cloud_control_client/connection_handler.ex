defmodule CloudControlClient.ConnectionHandler do
  use GenServer

  ## interface

  def start_link server_host, opts \\ [] do
    GenServer.start_link __MODULE__, server_host, opts
  end

  ## callbacks

  def init server_host do
    state = %{ server_host: server_host }

    {:ok, state}
  end
end
