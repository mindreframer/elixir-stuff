Code.require_file "../../test_helper.exs", __FILE__

defmodule StockServerTest.Timer do
  use ExUnit.Case, async: true

  test "getting the current time" do
    start_time = StockServer.Timer.current_time
    :timer.sleep(get_tick_rate() * 5)
    assert StockServer.Timer.current_time == start_time + 5
  end

  defp get_tick_rate do
    {:ok, tickrates} = :application.get_env(:stock_server, :tickrate)
    Keyword.get(tickrates, Mix.env)
  end
end
