defmodule StockServer.ConnectionSup do
  use Supervisor.Behaviour

  ## API
  def start_link do
    :supervisor.start_link({:local, __MODULE__}, __MODULE__, [])
  end

  def start_socket do
    :supervisor.start_child(__MODULE__, [])
  end

  def connection_states do
    children = :supervisor.which_children(__MODULE__)
    Enum.map children, fn({_, pid, _, _}) ->
      :gen_server.call(pid, :state)
    end
  end

  ## Callback

  def init([]) do
    init([StockServer.Connection])
  end

  def init([worker_module]) do
    {:ok, port} = :application.get_env(:stock_server, :port)

    {:ok, listen_socket} = :gen_tcp.listen(port, [{:active, :once}, {:packet, :line}])
    spawn_link(fn -> start_socket() end)
    
    supervise([ worker(worker_module, [listen_socket], restart: :temporary) ], strategy: :simple_one_for_one)
  end

end
