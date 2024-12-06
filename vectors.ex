defmodule Vectors do
  # Assuming a vector is a tuple of integers.
  def sum(vectors) do
    vectors
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.zip_with(&Enum.sum/1)
    |> List.to_tuple()
  end

  def add(a, b) do
    sum([a, b])
  end
end
