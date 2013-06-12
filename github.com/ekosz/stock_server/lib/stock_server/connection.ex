
defmodule StockServer.Connection do
  use GenServer.Behaviour

  defrecord State, lsocket: nil, account_pid: nil

  import StockServer.ConnectionSup, only: [start_socket: 0]

  ## API

  @doc """
  Starts a process listening on a socket.
  """
  def start_link(socket) do
    :gen_server.start_link(__MODULE__, [socket], [])
  end

  ## Callback

  def init([socket]) do
    :gen_server.cast(self(), :accept)
    {:ok, State[lsocket: socket]}
  end

  def handle_cast(:accept, State[lsocket: listen_socket] = state) do
    {:ok, _accept_socket} = :gen_tcp.accept(listen_socket)
    start_socket()
    {:ok, account_pid} = StockServer.AccountSup.start_account
    {:noreply, state.account_pid(account_pid)}
  end

  defp send(socket, message, args) do
    :ok = :gen_tcp.send(socket, :io_lib.format(message<>"~n", args))
    :ok = :inet.setopts(socket, [{:active, :once}])
    :ok
  end

  def handle_info({:tcp, socket, reply}, state) when is_binary(reply) do
    self <- {:tcp, socket, binary_to_list(reply)}
    {:noreply, state}
  end

  def handle_info({:tcp, socket, reply}, state) do
    response = try do
      :gen_server.call(state.account_pid, {:handle_command, reply})
    rescue
      error in _ -> 
        :error_logger.error_report(error)
        {:error, "server_error"}
    end

    case response do
      {:ok, message} ->
        send(socket, "OK "<>message, [])
        {:noreply, state}

      {:error, message} ->
        send(socket, "ERROR "<>message, [])
        {:noreply, state}

      {:stop, message} ->
        send(socket, message, [])
        :gen_tcp.close(socket)
        {:stop, :normal, state}
    end
  end
  
  def handle_info({:tcp_closed, _socket}, state) do
    {:stop, :normal, state}
  end

  def handle_info({:tcp_error, _socket}, state) do
    {:stop, :normal, state}
  end

  def terminate(_reason, state) do
    StockServer.AccountSup.stop(state.account_pid)
    :ok
  end

end
