defmodule Duration do

  defmacro {m1,s1} + {m2, s2} do
    quote do
      t_sec = rem(unquote(s1) + unquote(s2), 60)
      t_min = div(unquote(s1) + unquote(s2), 60)
      {unquote(m1) + unquote(m2) + t_min, t_sec}
    end
  end

  defmacro a + b do
    quote do
      unquote(a) + unquote(b)
    end
  end
end
