Code.require_file "../../test_helper.exs", __FILE__

defmodule StockServerTest.CSVReader do
  use ExUnit.Case

  test "reading a CSV file" do
    test_data = StockServer.CSVReader.read(:TEST)
    assert length(test_data) == 3
    assert Enum.at!(test_data, 0) == 26.50
    assert Enum.at!(test_data, 1) == 26.37
    assert Enum.at!(test_data, 2) == 26.87
  end
end
