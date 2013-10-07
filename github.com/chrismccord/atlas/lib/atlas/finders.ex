defmodule Atlas.Finders do

  @moduledoc """
  Provides `Model#find_by_[field]` finders to Atlas models.
  For every `field` definition, a `find_by_[field]` function will be defined taking
  a single argument as the value to match within the query.
  If a matched result is found, the first Model.Record is returned. Otherwise returns nil.

  Example
    defmodule User do
      use Atlas.Model

      field :email, :string
    end

    iex> User.find_by_email("user@example.com")
    User.Record[email: "user@example.com"]
  """

  defmacro __using__(_options) do
    quote do
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      Enum.each @fields, fn field ->
        field_name = elem(field, 0)
        def binary_to_atom("with_#{field_name}"), quote(do: [value]), [] do
          quote do
            where([{unquote(field_name), value}])
          end
        end
      end
    end
  end
end