defmodule PlutoPebbles do
  def has_even_number_of_digits(x) do
    Integer.to_string(x) |> String.length() |> Kernel.rem(2) == 0
  end

  def split_digits_in_half(x) do
    s = Integer.to_string(x)

    String.split_at(s, String.length(s) |> Kernel.div(2))
    |> Tuple.to_list()
    |> Enum.map(&String.to_integer/1)
  end

  def update_stone(x) do
    cond do
      x == 0 -> [1]
      has_even_number_of_digits(x) -> split_digits_in_half(x)
      true -> [x * 2024]
    end
  end

  def blink(stones) do
    Enum.map(stones, &update_stone/1) |> List.flatten()
  end

  def map_stone_count_after_n_blinks(stone, 0, acc), do: Map.put(acc, {stone, 0}, 1)

  def map_stone_count_after_n_blinks(stone, n, acc) do
    if Map.has_key?(acc, {stone, n}) do
      acc
    else
      new_stones = update_stone(stone)

      acc =
        new_stones
        |> Enum.reduce(acc, fn s, acc -> map_stone_count_after_n_blinks(s, n - 1, acc) end)

      new_count = new_stones |> Enum.map(&Map.get(acc, {&1, n - 1})) |> Enum.sum()
      Map.put(acc, {stone, n}, new_count)
    end
  end

  def count_stones_after_blinks(filename, n \\ 25) do
    stones = ReadInput.read_number_lists(filename) |> List.first()

    Enum.reduce(stones, {0, %{}}, fn s, {count, m} ->
      m = map_stone_count_after_n_blinks(s, n, m)
      {count + Map.get(m, {s, n}), m}
    end)
    |> elem(0)
  end
end

IO.inspect(PlutoPebbles.count_stones_after_blinks("input/day11Test.txt", 6) == 22)
IO.inspect(PlutoPebbles.count_stones_after_blinks("input/day11Test.txt", 25) == 55312)
IO.inspect(PlutoPebbles.count_stones_after_blinks("input/day11.txt", 25) == 189_167)

IO.inspect(PlutoPebbles.count_stones_after_blinks("input/day11.txt", 75) == 225_253_278_506_288)
