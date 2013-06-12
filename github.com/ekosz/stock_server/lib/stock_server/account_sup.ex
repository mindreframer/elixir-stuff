defmodule StockServer.AccountSup do
  use Supervisor.Behaviour

  ## API
  
  def start_link do
    :supervisor.start_link({:local, __MODULE__}, __MODULE__, [])
  end

  def start_account do
    :supervisor.start_child(__MODULE__, [])
  end

  def stop(pid) do
    :supervisor.terminate_child(__MODULE__, pid)
  end

  def states do
    accounts = :supervisor.which_children(__MODULE__)
    formatted_acconts = Enum.map accounts, fn({_, pid, _, _}) ->
      format(:gen_server.call(pid, :state))
    end
    formatted_acconts = remove_unregistered(formatted_acconts)
    Enum.sort formatted_acconts, fn({_,a,_,_}, {_,b,_,_}) -> 
      a > b 
    end
  end

  defp remove_unregistered(states) do
    Enum.filter states, fn(state) ->
      state.name != nil
    end
  end

  defp format(state) do
    {state.name, round_to_hundredth(net_worth(state.cash, state.stocks)), state.cash, state.stocks}
  end

  defp net_worth(cash, stocks) do
    Enum.reduce stocks, cash, fn({stock, amount}, acc) ->
      acc + (StockServer.Stock.current_price(stock) * amount)
    end
  end

  defp round_to_hundredth(number) do
    round(number * 100) / 100
  end

  ## CALLBACKS

  def init([]) do
    supervise([worker(StockServer.Account, [])], strategy: :simple_one_for_one)
  end

end
