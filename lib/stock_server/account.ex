defrecord StockServer.Account.State, name: nil, stocks: [], cash: 100_000

defmodule StockServer.Account do
  use GenServer.Behaviour

  alias StockServer.Account.State, as: State
  import StockServer.Connection.CommandHandler, only: [handle_command: 2]

  ### API
  
  def start_link do
    :gen_server.start_link(__MODULE__, [], [])
  end

  ### CALLBACKS

  def init([]) do
    {:ok, State.new}
  end

  def handle_call({:handle_command, command}, _form, state) do
    {status, message, new_state} = handle_command(command, state)

    {:reply, {status, message}, new_state}
  end

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end
end
