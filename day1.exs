defmodule Distance do
  def listDistance(lists) do
    lists
    |> Enum.map(&Enum.sort/1)
    |> Enum.zip
    |> Enum.map(fn {a, b} -> Kernel.abs(a-b) end)
    |> Enum.sum
  end

  def countInstances(enum, x) do
    enum
    |> Enum.filter(&(&1 == x))
    |> Enum.count
  end

  def listSimilarity([list1, list2]) do
    list1
    |> Enum.map(fn (term) -> term * countInstances(list2, term) end)
    |> Enum.sum
  end
end

exampleInput = ReadInput.readVerticalLists(("input/day1Test.txt"))
realInput = ReadInput.readVerticalLists(("input/day1.txt"))

IO.inspect Distance.listDistance(exampleInput)
IO.inspect Distance.listDistance(realInput)

IO.inspect Distance.listSimilarity(exampleInput)
IO.inspect Distance.listSimilarity(realInput)
