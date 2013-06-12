defmodule StockServer.Stock do
  use GenServer.Behaviour

  import StockServer.Stock.PressureCalculator, only: [pressure: 2]

  ## API

  @doc"""
  Starts the a server for a current stock
  """
  def start_link(stock) do
    :gen_server.start_link({:local, stock}, __MODULE__, [stock], [])
  end

  def current_price(id) do
    :gen_server.call(id, :current_price)
  end

  ## Callbacks

  defrecord State, prices: nil, current_price: nil, ticker: nil, 
                   pressure: 1, total_bought: 0, total_sold: 0

  def init([ticker]) do
    StockServer.Notifier.join_feed(self())

    prices = StockServer.CSVReader.read(ticker)
    {:ok, State[prices: prices, current_price: hd(prices), ticker: ticker]}
  end

  def handle_call(:current_price, _from, state) do
    {:reply, state.current_price, state}
  end

  def handle_call(_msg, _from, _state) do
    super
  end

  def handle_cast({:buy, stock, amount, price}, State[ticker: ticker, total_bought: bought] = state) when ticker == stock do
    state = state.total_bought(bought + amount * price)
    {:noreply, state}
  end

  def handle_cast({:sell, stock, amount, price}, State[ticker: ticker, total_sold: sold] = state) when ticker == stock do
    state = state.total_sold(sold + amount * price)
    {:noreply, state}
  end

  def handle_cast({:tick, time}, State[pressure: old_pressure, total_bought: bought, total_sold: sold] = state) do
    try do
      next_price = Enum.at!(state.prices, time)
      next_pressure = (old_pressure + pressure(bought, sold)) / 2
      {:noreply, state_from_price_and_pressure(state, next_price, next_pressure)}
    rescue
      Enum.OutOfBoundsError ->
        {:stop, :normal, state}
    end
  end

  def handle_cast(_msg, _state) do
    super
  end

  defp state_from_price_and_pressure(state, price, pressure) do
    state.current_price(price * pressure).pressure(pressure).total_sold(0).total_bought(0)
  end

end
