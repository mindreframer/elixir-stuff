defmodule Atlas.FieldConverter do

  @moduledoc """
  FieldConverter provides transformations from raw values returned from database or
  user input into value Elixir types based on Schema field types

  Examples

    iex> value_to_field_type("1", :float)
    1.0

  """
  def value_to_field_type(value, :string) when is_binary(value), do: value
  def value_to_field_type(nil,   :string), do: nil
  def value_to_field_type(value, :string), do: to_binary(value)

  def value_to_field_type(value, :integer) when is_integer(value), do: value
  def value_to_field_type(nil,   :integer), do: nil
  def value_to_field_type(value, :integer), do: elem(String.to_integer(value), 0)

  def value_to_field_type(value, :float) when is_float(value), do: value
  def value_to_field_type(value, :float) when is_integer(value), do: value + 0.0
  def value_to_field_type(nil,   :float), do: nil
  def value_to_field_type(value, :float) do
    case String.to_float(to_binary(value)) do
      {value, _} -> value
      :error     -> nil
    end
  end

  def value_to_field_type(value, :boolean) when is_boolean(value), do: value
  def value_to_field_type(value, :boolean), do: binary_to_atom(to_binary(value)) == true

  def value_to_field_type(value, :datetime) when is_binary(value), do: value
  def value_to_field_type(nil,   :datetime), do: nil
  def value_to_field_type(value, :datetime), do: value

  # handle undefined field type
  def value_to_field_type(value, nil), do: value
end