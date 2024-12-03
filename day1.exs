defmodule Distance do
  def list_distance(lists) do
    lists
    |> Enum.map(&Enum.sort/1)
    |> Enum.zip
    |> Enum.map(fn {a, b} -> Kernel.abs(a-b) end)
    |> Enum.sum
  end

  def count_instances(enum, x) do
    enum
    |> Enum.filter(&(&1 == x))
    |> Enum.count
  end

  def list_similarity([list1, list2]) do
    list1
    |> Enum.map(fn (term) -> term * count_instances(list2, term) end)
    |> Enum.sum
  end
end

exampleInput = ReadInput.read_vertical_lists(("input/day1Test.txt"))
realInput = ReadInput.read_vertical_lists(("input/day1.txt"))

IO.inspect Distance.list_distance(exampleInput)
IO.inspect Distance.list_distance(realInput)

IO.inspect Distance.list_similarity(exampleInput)
IO.inspect Distance.list_similarity(realInput)
