defmodule Powers do
  import Kernel, except: [raise: 2]

  @moduledoc """
  Function for raising a number to an integer power.
  from *Études for Elixir*, O'Reilly Media, Inc., 2013.
  Copyright 2013 by J. David Eisenberg.
  """
  @vsn 0.1

  @doc """
  Raise a number x to an integer power n.
  Any number to the power 0 equals 1.
  Any number to the power 1 is that number itself.
  When n is positive, x^n is equal to x times x^(n - 1)
  When n is negative, x^n is equal to 1.0 / x^n
  """
  
  @spec raise(number(), number()) :: number()

  def raise(_, 0) do
    1
  end
  
  def raise(x, 1) do
    x
  end
  
  def raise(x, n) when n > 0 do
    IO.puts("Enter with x = #{x}, n = #{n}")
    result = x * raise(x, n - 1)
    IO.puts("Result is #{result}")
    result
  end
  
  def raise(x, n) when n < 0 do
    1.0 / raise(x, -n)
  end
end
