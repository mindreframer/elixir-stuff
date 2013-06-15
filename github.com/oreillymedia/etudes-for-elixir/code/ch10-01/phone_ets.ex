defrecord Phone, number: "", start_date: "1900-01-01",
  start_time: "00:00:00", end_date: "1900-01-01",
  end_time: "00:00:00"
  
defmodule PhoneEts do
  @moduledoc """ 
  Validate input using regular expressions.
  
  from *Études for Elixir*, O'Reilly Media, Inc., 2013.
  Copyright 2013 by J. David Eisenberg.
  """ 
  @vsn 0.1 

  @doc """
  Given a file name containing a CSV table of phone number,
  start date/time, and end date/time, construct a corresponding
  ETS table.
  """
  @spec setup(String.t) :: atom
  
  def setup(file_name) do
    # delete table if it exists
    case :ets.info(:call_table) do
      :undefined -> false
      _ -> :ets.delete(:call_table)
    end

    :ets.new(:call_table, [:named_table, :bag,
      {:keypos, Phone.__index__(:number) + 1}])
    {result, input_file} = File.open(file_name)
    if result == :ok do
      add_rows(input_file)
    end
  end
  
  #
  # Recursively read input file and add rows to
  # the ETS table.
  @spec add_rows(IO.device) :: atom
  
  defp add_rows(input_file) do
    data = IO.readline(input_file)
    cond do
      data != :eof ->
        [number, sdate, stime, edate, etime] =
          String.split(String.strip(data), ",")
        :ets.insert(:call_table, Phone.new(number: number,
          start_date: gregorianize(sdate, "-"),
          start_time: gregorianize(stime, ":"),
          end_date: gregorianize(edate, "-"),
          end_time: gregorianize(etime, ":")))
        add_rows(input_file)
      true ->
        :ok
    end
  end
  
  # Convert a time or date string (given its delimiter, : or -)
  # to a three-tuple of the constituent elements
  @spec gregorianize(String.t, String.t) :: {integer, integer, integer}
  
  defp gregorianize(str, delimiter) do
    list_to_tuple(lc item inlist String.split(str, delimiter), do:
      binary_to_integer(item))
  end   
  
  @doc """
  Summarize the number of minutes for a given phone number.
  """
  @spec summary(String.t) :: list(tuple(String.t, integer))
  
  def summary(phone_number) do
    [calculate(phone_number)]
  end
  
  @doc """
  Summarize the number of minutes for all phone numbers in the
  data bases.
  """
  @spec summary(String.t) :: list(tuple(String.t, integer))
  
  def summary() do
    summary(:ets.first(:call_table), [])
  end
  
  defp summary(key, acc) do
    case key do
      :"$end_of_table" -> acc
      _ -> summary(:ets.next(:call_table, key),
        [calculate(key) | acc])
    end
  end
  
  # Calculate total number of minutes used by given phone number.
  # Returns tuple {phone_number, total}
  @spec calculate(String.t) :: {String.t, integer}
  
  defp calculate(phone_number) do
    calls = :ets.lookup(:call_table, phone_number)
    total = List.foldl(calls, 0, call_minutes(&1, &2))
    {phone_number, total}
  end
  
  # Helper function for calculate; adds the number of minutes
  # for a given call to the accumulator  
  @spec call_minutes(Phone.t, integer) ::integer
  
  defp call_minutes(call, acc) do
    c_start = :calendar.datetime_to_gregorian_seconds({call.start_date,
      call.start_time})
    c_end = :calendar.datetime_to_gregorian_seconds({call.end_date,
      call.end_time})
    div((c_end - c_start) + 59, 60) + acc
  end
end
