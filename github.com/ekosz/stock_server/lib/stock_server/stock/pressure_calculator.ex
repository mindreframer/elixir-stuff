defmodule StockServer.Stock.PressureCalculator do

  def pressure(total_bought, total_sold) do
    calc_bought(total_bought) / calc_sold(total_sold)
  end

  defp calc_bought(amount) do
    1 + (amount / 100_000)
  end

  defp calc_sold(amount) do
    1 + (amount / 100_000)
  end
end
