defmodule Reports do

  def isSafelyIncreasing([]), do: true
  def isSafelyIncreasing([_ | []]), do: true
  def isSafelyIncreasing([h | t]) do
    next = hd(t)
    next > h && (next - h) <= 3 && isSafelyIncreasing(t)
  end

  def isSafelyDecreasing([]), do: true
  def isSafelyDecreasing([_ | []]), do: true
  def isSafelyDecreasing([h | t]) do
    next = hd(t)
    next < h && (h - next) <= 3 && isSafelyDecreasing(t)
  end

  def isSafe(list) do
    isSafelyIncreasing(list) || isSafelyDecreasing(list)
  end

  def countSafe(list) do
    Enum.count(list, &isSafe/1)
  end

  def droppedItemPermutations(list) do
    Enum.map(0..(length(list) - 1), fn i -> List.pop_at(list, i) end)
    |> Enum.map(fn {_, l} -> l end)
  end
  def isSafeWithDampener(list) do
    Enum.any?(droppedItemPermutations(list), &isSafe/1)
  end
  def countSafeWithDampener(list) do
    Enum.count(list, &isSafeWithDampener/1)
  end
end

exampleInput = ReadInput.readNumberLists(("input/day2Test.txt"))
realInput = ReadInput.readNumberLists(("input/day2.txt"))

IO.inspect Reports.countSafe(exampleInput)
IO.inspect Reports.countSafe(realInput)

IO.inspect Reports.countSafeWithDampener(exampleInput)
IO.inspect Reports.countSafeWithDampener(realInput)
