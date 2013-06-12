defmodule StockServerTest.Stock.PressureCalculator do
  use ExUnit.Case, async: true

  alias StockServer.Stock.PressureCalculator, as: Calc

  test "the pressure for $100,000 of stock being bought is 2" do
    assert Calc.pressure(100_000, 0) == 2
  end

  test "the pressure for $100,000 of stock being sold is 0.5" do
    assert Calc.pressure(0, 100_000) == 0.5
  end

  test "the pressure for $100,000 of stock being sold and $100,000 of stock being bought is 1" do
    assert Calc.pressure(100_000, 100_000) == 1
  end
end
