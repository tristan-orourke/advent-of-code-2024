defmodule Reports do

  def is_safely_increasing([]), do: true
  def is_safely_increasing([_ | []]), do: true
  def is_safely_increasing([h | t]) do
    next = hd(t)
    next > h && (next - h) <= 3 && is_safely_increasing(t)
  end

  def is_safely_decreasing([]), do: true
  def is_safely_decreasing([_ | []]), do: true
  def is_safely_decreasing([h | t]) do
    next = hd(t)
    next < h && (h - next) <= 3 && is_safely_decreasing(t)
  end

  def is_safe(list) do
    is_safely_increasing(list) || is_safely_decreasing(list)
  end

  def count_safe(list) do
    Enum.count(list, &is_safe/1)
  end

  def dropped_item_permutations(list) do
    Enum.map(0..(length(list) - 1), fn i -> List.pop_at(list, i) end)
    |> Enum.map(fn {_, l} -> l end)
  end
  def is_safe_with_dampener(list) do
    Enum.any?(dropped_item_permutations(list), &is_safe/1)
  end
  def count_safe_with_dampener(list) do
    Enum.count(list, &is_safe_with_dampener/1)
  end
end

exampleInput = ReadInput.read_number_lists(("input/day2Test.txt"))
realInput = ReadInput.read_number_lists(("input/day2.txt"))

IO.inspect Reports.count_safe(exampleInput)
IO.inspect Reports.count_safe(realInput)

IO.inspect Reports.count_safe_with_dampener(exampleInput)
IO.inspect Reports.count_safe_with_dampener(realInput)
