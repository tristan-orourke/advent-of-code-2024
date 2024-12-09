defmodule Defragmenter do
  def is_even(i), do: Integer.mod(i, 2) == 0

  def parse_disk_map(s) do
    String.graphemes(s)
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index(fn element, index ->
      %{id: if(is_even(index), do: Integer.floor_div(index, 2), else: :empty), length: element}
    end)
  end

  def defrag_disk_map([], _, acc), do: acc

  def defrag_disk_map([block | _], [source_block | _], acc) when block.id == source_block.id,
    do: [source_block | acc]

  def defrag_disk_map([block | disk_map], source_blocks, acc) when block.id != :empty,
    do: defrag_disk_map(disk_map, source_blocks, [block | acc])

  def defrag_disk_map(
        [%{id: :empty, length: empty_space} | disk_map],
        [block | source_blocks],
        acc
      ) do
    cond do
      block.length == empty_space ->
        defrag_disk_map(disk_map, source_blocks, [block | acc])

      block.length < empty_space ->
        defrag_disk_map(
          [%{id: :empty, length: empty_space - block.length} | disk_map],
          source_blocks,
          [
            block | acc
          ]
        )

      block.length > empty_space ->
        defrag_disk_map(
          disk_map,
          [%{id: block.id, length: block.length - empty_space} | source_blocks],
          [%{id: block.id, length: empty_space} | acc]
        )
    end
  end

  def defrag_disk_map(disk_map) do
    source_blocks = Enum.filter(disk_map, fn %{id: id} -> id != :empty end) |> Enum.reverse()

    defrag_disk_map(disk_map, source_blocks, [])
    |> Enum.reverse()
  end

  def expand_disk_map(disk_map) do
    Enum.flat_map(disk_map, fn %{id: id, length: length} -> List.duplicate(id, length) end)
  end

  def part_1(filename) do
    ReadInput.read_string(filename)
    |> parse_disk_map()
    |> defrag_disk_map()
    |> expand_disk_map()
    # |> Enum.join()
    |> Enum.with_index()
    |> Enum.map(fn {element, index} -> element * index end)
    |> Enum.sum()
  end
end

IO.inspect(Defragmenter.part_1("input/day9Test.txt") == 1928)
IO.inspect Defragmenter.part_1("input/day9.txt")
