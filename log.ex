defmodule Log do
  def wrap(f) when is_function(f, 0), do: fn -> inspect(f.()) end
  def wrap(f) when is_function(f, 1), do: fn x -> inspect(f.(x)) end
  def wrap(f) when is_function(f, 2), do: fn x, y -> inspect(f.(x, y)) end
  def wrap(f) when is_function(f, 3), do: fn x, y, z -> inspect(f.(x, y, z)) end

  def log(value) do
    IO.inspect(value)
    value
  end

  def timing(f, args \\ []) do
    {microseconds, result} = :timer.tc(f, args)
    IO.puts("Execution time: #{microseconds / 1_000_000} seconds")
    IO.puts("Result: #{inspect(result)}")
    result
  end
end
