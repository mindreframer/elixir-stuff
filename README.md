Interacting with the Server
===========================

All communication with the stock server happens over simple TCP Sockets.  As long as your socket is open you can continue to send commands
and read the resonces.  If your socket is closed, your progress will be lost. (This may change in the future)

Server Responses
===============

All server responses start with `OK` or `ERROR`, are space deliminated, and end with a newline.

Server Commands
============

All server commands are sent via TCP and are delimitated with a newline.  

Ruby example

```ruby
require 'socket'

s = TCPSocket.new('localhost', 3000)
s.write("register AwesomeCo\n")
s.gets #=> "OK registered\n"
```

quit
-----

Closes the TCP connection.

Server Responses

> OK -> "Goodbye\n"

register \<name\>
---------------------

Registers yourself with the server.  This is one of the only two commands you can run without registering first.

Params

> `name` - The name of your trading company

Server Responses

> OK -> "OK registered\n"

list_stocks
--------------

Lists all tradable stocks, as time progresses more might apear on this list as they have their IPOs.  All stock tickers are separated by spaces.

> OK -> "OK AAPL MSFT ....\n"

current_cash
------------------

Returns the amount of free cash your company has on hand.

Server Responses

> OK -> "OK 1034.54\n"

current_stocks
--------------------

Lists current amount of owned stocks.  The response returns pairs of stock tickers and amounts.

Server Responses

> OK -> "OK AAPL 30 MSFT 10 ...\n"

> Don't own any stocks -> "ERROR no_stocks\n"

price \<ticker\>
--------------------

Returns the current price of a stock.

Params

> `ticker` -> A stock ticker like 'AAPL' or 'MSFT'

Server Responses

> OK -> "OK 13.45\n"

buy \<ticker\> \<amount\>
----------------------------------

Tries to buy a certain amount of stock.

Params

> `ticker` -> A stock ticker like 'AAPL' or 'MSFT'

> `amount` -> A whole number like 30 or 22

Server Responses 

> OK -> "OK BOUGHT AAPL 100 39.88\n"

> Not enough money -> "ERROR insufficient_cash\n"

sell \<ticker\> \<amount\>
-----------------------

Tries to sell a certain amount of stock.

Params

> `ticker` -> A stock ticker like 'AAPL' or 'MSFT'

> `amount` -> A whole number like 30 or 22

Server Responses

> OK -> "OK SOLD AAPL 100 39.88\n"

> Not enough stocks -> "ERROR insufficient_stocks\n"

Ruby Client
===========

To get yourself started, here is a bare bones ruby client you can use to interact with the server.

```ruby
require 'socket'

class StockServer

  def initialize(host, port)
    @socket = TCPSocket.new(host, port)
  end
  
  def close
    @socket.close
  end
  
  def register(name)
    send_command("register #{name}")
  end
  
  def list_stocks
    send_command("list_stocks")
  end
  
  def current_cash
    send_command("current_cash")
  end
  
  def current_stocks
    send_command("current_stocks")
  end
  
  def price(ticker)
    send_command("price #{ticker}")
  end
  
  def buy(ticker, amount)
    send_command("buy #{ticker} #{amount}")
  end
  
  def sell(ticker, amount)
    send_command("sell #{ticker} #{amount}")
  end
  
  private
  
  def send_command(command)
    @socket.puts(command)
    @socket.gets
  end
end
```
