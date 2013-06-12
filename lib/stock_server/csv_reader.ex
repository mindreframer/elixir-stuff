defmodule StockServer.CSVReader do
  @doc """
  Reads a csv file located in the data/ directory

  ## Example

      read(:APPL) #=> Reads and parses data/appl.csv

  """

  def read(stock) do
    {:ok, io_device} = :file.open(file_path(stock), [:read])

    collect = fn(line, {count, prices}) ->
      {count + 1, prices ++ parse(count, line)}
    end

    {:ok, collector} = :ecsv.process_csv_file_with(io_device, collect, {0, []})

    elem collector, 1
  end

  defp file_path(stock) do
    "data/#{String.downcase(atom_to_binary(stock))}.csv"
  end

  defp parse(0, _line) do
    [] # Ignore the first line
  end

  defp parse(_count, {:newline, [_date, _open, _high, _low, close, _volume, _adj_close]}) do
    [list_to_float(close)]
  end

  defp parse(_count, {:eof}) do
    []
  end
end
