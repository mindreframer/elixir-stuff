# This file defines the Dynamo.Exception protocol and
# the exceptions that implement such protocol.

defprotocol Dynamo.Exception do
  @moduledoc """
  This protocol specifies how Dynamo should react to specific
  exceptions. particularly, the status code to be used when an
  exception happens.
  """

  @only [Record, Any]

  @doc """
  Receives the exception. It must return an integer
  representing the exception status code or a tuple
  containing the forementioned integer and a connection
  in case the exception holds a connection.
  """
  def status(exception)
end

defimpl Dynamo.Exception, for: Any do
  def status(_), do: 500
end

defexception Dynamo.NotFoundError, conn: nil, message: "no route found" do
  defimpl Dynamo.Exception do
    def status(exception) do
      { 404, exception.conn }
    end
  end
end
