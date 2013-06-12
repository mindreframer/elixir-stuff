defmodule StockServer.Connection.CommandHandler do

  alias StockServer.Account.State, as: State

  import StockServer.Notifier, only: [notify_buy: 3, notify_sell: 3]

  def handle_command('quit'++_, state) do
    {:stop, "Goodbye", state}
  end

  def handle_command('register '++team, state) do
    {:ok, "registered", state.name(line(team))}
  end

  def handle_command(_command, State[name: nil] = state) do
    {:error, "not_registered", state}
  end

  def handle_command('list_stocks'++_, state) do
    message = Enum.reduce StockServer.StockSup.all_stocks, "", fn(stock, msg) ->
      msg<>"#{stock} "
    end
    {:ok, message, state}
  end

  def handle_command('price '++rest, state) do
    price = StockServer.Stock.current_price(extract_stock(first_word(rest)))
    {:ok, format_price(price), state}
  end

  def handle_command('current_cash'++_, State[cash: cash] = state) do
    {:ok, format_price(cash), state}
  end

  def handle_command('current_stocks'++_, State[stocks: []] = state) do
    {:error, "no_stocks", state}
  end

  def handle_command('current_stocks'++_, state) do
    message = Enum.reduce state.stocks, "", fn(stock, acc) ->
      acc <> "#{elem stock, 0} #{elem stock, 1} "
    end
    {:ok, message, state}
  end

  def handle_command('buy '++rest, state) do
    [stock, amount] = retrive_stock_and_amount(rest)
    current_price = StockServer.Stock.current_price(stock)
    buy(stock, amount, current_price, state)
  end

  def handle_command('sell '++rest, state) do
    [stock, amount] = retrive_stock_and_amount(rest)
    current_amount = Keyword.get(state.stocks, stock, 0)
    sell(stock, amount, current_amount, state)
  end

  def handle_command(_command, state) do
    {:error, "unknown_command", state}
  end

  defp buy(_stock, amount, _current_price, state) when amount < 0 do
    {:error, "CHEATER", state}
  end

  defp buy(_stock, amount, current_price, State[cash: cash] = state) when amount * current_price > cash do
    {:error, "insufficient_cash", state}
  end

  defp buy(stock, amount, current_price, State[cash: cash] = state) do
    current_amount = Keyword.get(state.stocks, stock, 0)

    state = state.stocks(
      Keyword.put(state.stocks, stock, current_amount+amount)
    ).cash(cash - round_to_hundredth(current_price * amount))

    notify_buy(stock, amount, current_price)

    {:ok, "BOUGHT #{stock} #{amount} #{format_price(current_price)}", state}
  end

  defp sell(_stock, amount, _current_ammount, state) when amount < 0 do
    {:error, "CHEATER", state}
  end

   defp sell(_stock, amount, current_amount, state) when amount > current_amount do
    {:error, "insufficient_stocks", state}
  end

  defp sell(stock, amount, current_amount, State[cash: cash] = state) do
    current_price = StockServer.Stock.current_price(stock)

    state = state.stocks(
      Keyword.put(state.stocks, stock, current_amount - amount)
    ).cash(cash + round_to_hundredth(amount * current_price))

    notify_sell(stock, amount, 100)

    {:ok, "SOLD #{stock} #{amount} #{format_price(current_price)}", state}
  end

  defp format_price(price) do
    list_to_binary(:io_lib.format('~.2f',[float(price)]))
  end

  defp round_to_hundredth(number) do
    round(number * 100) / 100
  end

  defp retrive_stock_and_amount(string) do
    [stock, amount] = :string.tokens(string, '\r\n ')
    stock  = extract_stock(stock)
    amount = list_to_integer(amount)
    [stock, amount]
  end

  defp extract_stock(string) do
    binary_to_atom(String.upcase(list_to_binary(string)))
  end

  defp first_word(string) do
    hd :string.tokens(string, '\r\n ')
  end

  defp line(string) do
    hd :string.tokens(string, '\r\n')
  end  
end
