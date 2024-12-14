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

  def find_first_empty_block_of_length(blocks, length, mem) do
    last_known_position = Map.get(mem, length, 0)

    if last_known_position == nil do
      nil
    else
      Enum.slice(blocks, last_known_position..-1//1)
      |> Enum.find_index(fn %{id: id, length: l} ->
        id == :empty and l >= length
      end)
      |> case do
        nil -> nil
        index -> index + last_known_position
      end
    end
  end

  def compact_disk_map([], disk_map_back, _), do: disk_map_back

  def compact_disk_map(disk_map_front, disk_map_back, mem) do
    {block, disk_map_front} = List.pop_at(disk_map_front, -1)

    case block.id do
      :empty ->
        compact_disk_map(
          disk_map_front,
          [block | disk_map_back],
          mem
        )

      _ ->
        position_of_sufficient_empty_block =
          find_first_empty_block_of_length(disk_map_front, block.length, mem)

        if position_of_sufficient_empty_block == nil do
          compact_disk_map(
            disk_map_front,
            [block | disk_map_back],
            Map.put(mem, block.length, nil)
          )
        else
          empty_block =
            Enum.at(disk_map_front, position_of_sufficient_empty_block)

          space_left = empty_block.length - block.length

          compact_disk_map(
            Enum.slice(disk_map_front, 0..(position_of_sufficient_empty_block - 1)//1) ++
              [block] ++
              if(space_left > 0, do: [%{id: :empty, length: space_left}], else: []) ++
              Enum.slice(disk_map_front, (position_of_sufficient_empty_block + 1)..-1//1),
            [%{id: :empty, length: block.length} | disk_map_back],
            Map.put(
              mem,
              block.length,
              position_of_sufficient_empty_block
            )
          )
        end
    end
  end

  def compact_disk_map(disk_map) do
    compact_disk_map(disk_map, [], Map.new())
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

  def part_2(filename) do
    ReadInput.read_string(filename)
    |> parse_disk_map()
    |> compact_disk_map()
    |> expand_disk_map()
    # |> Enum.map(fn element -> if(element == :empty, do: ".", else: element) end)
    # |> Enum.join()
    |> Enum.with_index()
    |> Enum.map(fn {element, index} -> if(element == :empty, do: 0, else: element * index) end)
    |> Enum.sum()
  end
end

IO.inspect(Defragmenter.part_1("input/day9Test.txt") == 1928)
IO.inspect(Defragmenter.part_1("input/day9.txt") == 6_398_252_054_886)

IO.inspect(Defragmenter.part_2("input/day9Test.txt") == 2858)
IO.inspect(Defragmenter.part_2("input/day9.txt") == 6415666220005)
