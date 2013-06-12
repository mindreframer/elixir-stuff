defmodule StockServer.StockSup do
  use Supervisor.Behaviour

  ## API
  def start_link do
    :supervisor.start_link({:local, __MODULE__}, __MODULE__, [])
  end

  def all_stocks do
    Enum.map :supervisor.which_children(__MODULE__), fn({id, _pid, _type, _modules}) ->
      id
    end
  end

  ## Callbacks

  def init([]) do
    stocks = [:AAPL, :BAC, :C, :GE, :HAS, :XOM]

    workers = Enum.map stocks, fn(stock) ->
      worker(StockServer.Stock, [stock], id: stock)
    end

    supervise(workers, strategy: :one_for_one)
  end
end
