defmodule Resonance do
  def map_antennae_locations(matrix) do
    Enum.with_index(matrix)
    |> Enum.map(fn {row, y} ->
      Enum.with_index(row) |> Enum.map(fn {value, x} -> {value, {x, y}} end)
    end)
    |> List.flatten()
    |> Enum.filter(fn {value, _} -> value != "." end)
    |> Enum.reduce(%{}, fn {value, location}, acc ->
      Map.update(acc, value, [location], &[location | &1])
    end)
  end

  def make_all_pairs(list, acc \\ [])
  def make_all_pairs([], acc), do: acc
  def make_all_pairs([_], acc), do: acc

  def make_all_pairs([head | tail], acc) do
    acc = Enum.reduce(tail, acc, fn x, acc -> [{head, x} | acc] end)
    make_all_pairs(tail, acc)
  end

  def make_antinodes({loc1, loc2}) do
    diff = Vectors.subtract(loc1, loc2)
    {Vectors.add(loc1, diff), Vectors.subtract(loc2, diff)}
  end

  def make_antinodes_extended({loc1, loc2}, height, width) do
    diff = Vectors.subtract(loc1, loc2)
    stream1 = Stream.iterate(loc1, &Vectors.add(&1, diff))
    stream2 = Stream.iterate(loc2, &Vectors.subtract(&1, diff))

    Enum.concat([
      Stream.take_while(stream1, &within_bounds?(&1, height, width)),
      Stream.take_while(stream2, &within_bounds?(&1, height, width))
    ])
    |> List.to_tuple()
  end

  def within_bounds?({x, y}, height, width) do
    x >= 0 and y >= 0 and y < height and x < width
  end

  def count_antinode_locations(filename) do
    matrix = ReadInput.read_char_matrix_as_lists(filename)

    matrix
    |> map_antennae_locations()
    |> Enum.map(fn {frequency, locations} ->
      {frequency,
       make_all_pairs(locations)
       |> Enum.map(&make_antinodes/1)
       |> Enum.flat_map(&Tuple.to_list/1)}
    end)
    |> Enum.flat_map(fn {_, antinodes} -> antinodes end)
    |> Enum.uniq()
    |> Enum.filter(&within_bounds?(&1, length(matrix), length(hd(matrix))))
    |> Enum.count()
  end

  def count_extended_antinode_locations(filename) do
    matrix = ReadInput.read_char_matrix_as_lists(filename)
    height = length(matrix)
    width = length(hd(matrix))

    matrix
    |> map_antennae_locations()
    |> Enum.map(fn {frequency, locations} ->
      {frequency,
       make_all_pairs(locations)
       |> Enum.map(&make_antinodes_extended(&1, height, width))
       |> Enum.flat_map(&Tuple.to_list/1)}
    end)
    |> Enum.flat_map(fn {_, antinodes} -> antinodes end)
    |> Enum.uniq()
    |> Enum.filter(&within_bounds?(&1, height, width))
    |> Enum.count()
  end
end

IO.inspect(Resonance.count_antinode_locations("input/day8Test2.txt") == 1)
IO.inspect(Resonance.count_antinode_locations("input/day8Test.txt") == 14)
IO.inspect(Resonance.count_antinode_locations("input/day8.txt") == 364)

IO.inspect(Resonance.count_extended_antinode_locations("input/day8Test.txt") == 34)
Log.timing fn -> Resonance.count_extended_antinode_locations("input/day8.txt") == 1231 end
