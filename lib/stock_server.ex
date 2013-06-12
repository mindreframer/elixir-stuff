defmodule StockServer do
  use Application.Behaviour

  ## API
  
  @doc """
  Starts the application
  """
  def start(_type, args) do
    StockServerSup.start_link(args)
  end

  def score_board do
    IO.puts "Name, Net Worth, Cash, Stocks"
    score_board(StockServer.AccountSup.states)
  end

  def score_board([]) do
    IO.puts "That's it!"
  end

  def score_board([h|t]) do
    IO.inspect h
    score_board(t)
  end

end
