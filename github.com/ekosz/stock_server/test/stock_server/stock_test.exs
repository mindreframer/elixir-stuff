Code.require_file "../../test_helper.exs", __FILE__

defmodule StockServerTest.Stock do
  use ExUnit.Case

  test "creating a stock server" do
    assert {:ok, pid} = StockServer.Stock.start_link(:TEST)
    assert is_pid(pid)
  end
end
