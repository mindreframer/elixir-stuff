defexception Atlas.Exceptions.AdapterError,
             message: "Error when performing query",
             can_retry: false do

  def full_message(me) do
    "Call failed: #{me.message}, retriable: #{me.can_retry}"
  end
end