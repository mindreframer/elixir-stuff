defmodule StockServer.Timer do
  use GenServer.Behaviour

  import StockServer.Notifier, only: [notify_tick: 1]

  ## API

  def start_link do
    :gen_server.start_link({:local, __MODULE__}, __MODULE__, [], [])
  end

  def current_time do
    :gen_server.call(__MODULE__, :current_time)
  end

  ## Callbacks
  defrecord State, time: 0, tick_rate: nil

  def init([]) do
    {:ok, tickrates} = :application.get_env(:stock_server, :tickrate)
    time_to_wait = Keyword.get(tickrates, Mix.env)
    {:ok, _ } = :timer.send_after(time_to_wait, :tick)

    {:ok, State[tick_rate: time_to_wait]}
  end

  def handle_call(:current_time, _from, state) do
    {:reply, state.time, state}
  end

  def handle_call(_msg, _from, _state) do
    super
  end

  def handle_info(:tick, state) do
    notify_tick(state.time)
    {:ok, _} = :timer.send_after(state.tick_rate, :tick)
    {:noreply, updated_time(state)}
  end

  def handle_info(_msg, _state) do
    super
  end

  ## Privates

  defp updated_time(state) do
    State[time: state.time+1, tick_rate: state.tick_rate]
  end

end
