defmodule Ecto.Query.GroupByBuilderTest do
  use ExUnit.Case, async: true

  import Ecto.Query.GroupByBuilder

  test "escape" do
    varx = { :{}, [], [:&, [], [0]] }
    vary = { :{}, [], [:&, [], [1]] }

    assert [{ varx, :y }] ==
           escape(quote do x.y end, [:x])

    assert [{ varx, :x }, { vary, :y }] ==
           escape(quote do [x.x, y.y] end, [:x, :y])
  end

  test "escape raise" do
    assert_raise Ecto.InvalidQuery, "unbound variable `x` in query", fn ->
      escape(quote do x.y end, [])
    end

    message = "malformed group_by query"
    assert_raise Ecto.InvalidQuery, message, fn ->
      escape(quote do 1 + 2 end, [])
    end
  end
end
