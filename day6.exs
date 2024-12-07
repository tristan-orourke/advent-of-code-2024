defmodule MapComputer do
  @up {0, -1}
  @down {0, 1}
  @left {-1, 0}
  @right {1, 0}

  def turn_right(direction) do
    case direction do
      @up -> @right
      @right -> @down
      @down -> @left
      @left -> @up
    end
  end

  def position_is_open?(matrix, {x, y}) do
    Vectors.matrix_elem(matrix, {x, y}) != "#"
  end

  def update_state(
        %Computer.State{
          output: output
        } = state,
        new_registers
      ) do
    state
    |> Map.replace(:registers, new_registers)
    |> Map.replace(:output, [new_registers | output])
  end

  def movement_interpreter(
        %Computer.State{
          program: obstacle_map,
          registers: %{position: {px, py}, direction: direction}
        } = computer
      ) do
    new_corner =
      case direction do
        @up ->
          {px,
           (Enum.reverse(Map.get(obstacle_map.columns, px, [])) |> Enum.find(-1, &(&1 < py))) + 1}

        @down ->
          {px,
           (Map.get(obstacle_map.columns, px, []) |> Enum.find(obstacle_map.height, &(&1 > py))) -
             1}

        @left ->
          {(Enum.reverse(Map.get(obstacle_map.rows, py, [])) |> Enum.find(-1, &(&1 < px))) + 1,
           py}

        @right ->
          {(Map.get(obstacle_map.rows, py, []) |> Enum.find(obstacle_map.width, &(&1 > px))) - 1,
           py}
      end

    {new_x, new_y} = new_corner

    is_going_out_of_bounds =
      case direction do
        @up -> new_y == 0
        @down -> new_y == obstacle_map.height - 1
        @left -> new_x == 0
        @right -> new_x == obstacle_map.width - 1
      end

    new_direction = turn_right(direction)

    new_registers =
      Map.replace!(computer.registers, :position, new_corner)
      |> Map.replace!(:direction, new_direction)

    cond do
      # If we're out of bounds, we're done.
      is_going_out_of_bounds ->
        {:halt,
         update_state(
           computer,
           %{new_registers | end_state: :out_of_bounds}
         )}

      # If we've encounter this exact position before, we're stuck in a loop
      Enum.any?(computer.output, fn %{position: prev_position, direction: prev_direction} ->
        new_corner == prev_position and new_direction == prev_direction
      end) ->
        {:halt,
         update_state(
           computer,
           %{new_registers | end_state: :loop}
         )}

      # Otherwise, turn and continue
      true ->
        {:cont, update_state(computer, new_registers)}
    end
  end

  def find_position_in_matrix(char_matrix, char) do
    Enum.reduce_while(Tuple.to_list(char_matrix), 0, fn row, y ->
      case Enum.find_index(Tuple.to_list(row), &(&1 == char)) do
        nil -> {:cont, y + 1}
        x -> {:halt, {x, y}}
      end
    end)
  end

  # Assumes the matrix is rectangular
  def char_matrix_to_obstacle_map(char_matrix) do
    Vectors.list_all_matrix_positions(char_matrix)
    |> Enum.filter(fn {x, y} -> not position_is_open?(char_matrix, {x, y}) end)
    |> Enum.reduce(%{rows: %{}, columns: %{}}, fn {x, y}, acc ->
      row = Map.get(acc.rows, y, [])
      column = Map.get(acc.columns, x, [])

      %{
        rows: Map.put(acc.rows, y, row ++ [x]),
        columns: Map.put(acc.columns, x, column ++ [y]),
        height: tuple_size(char_matrix),
        width: tuple_size(elem(char_matrix, 0))
      }
    end)
  end

  def init(char_matrix) do
    initial_position = find_position_in_matrix(char_matrix, "^")

    %Computer.State{
      program: char_matrix_to_obstacle_map(char_matrix),
      registers: %{position: initial_position, direction: @up, end_state: nil},
      output: [%{position: initial_position, direction: @up}]
    }
  end

  def count_unique_positions_visited(input_file) do
    ReadInput.read_char_matrix(input_file)
    |> init()
    |> Computer.run(&movement_interpreter/1)
    |> Map.get(:output)
    |> Enum.map(&Map.get(&1, :position))
    |> interpolate_corners()
    |> Enum.uniq()
    |> Enum.count()
  end

  def place_obstruction(obstruction_map, {x, y}) do
    updated_row = (Map.get(obstruction_map.rows, y, []) ++ [x]) |> Enum.sort()
    updated_col = (Map.get(obstruction_map.columns, x, []) ++ [y]) |> Enum.sort()

    obstruction_map
    |> Map.put(:rows, Map.put(obstruction_map.rows, y, updated_row))
    |> Map.put(:columns, Map.put(obstruction_map.columns, x, updated_col))
  end

  def obstruction_will_cause_loop(obstruction_position, original_state) do
    if obstruction_position == original_state.registers.position do
      # We're not allowed to obstruct the initial position
      false
    else
      ends_in_loop = fn state -> state.registers.end_state == :loop end

      original_state
      |> Map.update!(:program, &place_obstruction(&1, obstruction_position))
      |> Computer.run(&movement_interpreter/1)
      |> ends_in_loop.()
    end
  end

  def drop_last(list) do
    list |> Enum.reverse() |> tl |> Enum.reverse()
  end

  def interpolate_corners(list, acc \\ [])
  def interpolate_corners([corner | []], acc), do: acc ++ [corner]

  def interpolate_corners([{x1, y1} | rest], acc) do
    {x2, y2} = hd(rest)

    section =
      if(x1 == x2,
        do: Enum.map(0..(y2 - y1), fn i -> {x1, y1 + i} end),
        else: Enum.map(0..(x2 - x1), fn i -> {x1 + i, y1} end)
      )

    interpolate_corners(rest, acc ++ drop_last(section))
  end

  def count_obstructions_which_cause_loop(input_file) do
    original_state = ReadInput.read_char_matrix(input_file) |> init()

    original_state
    |> Computer.run(&movement_interpreter/1)
    |> Map.get(:output)
    |> Enum.map(&Map.get(&1, :position))
    |> interpolate_corners()
    |> Enum.uniq()
    |> Enum.map(&obstruction_will_cause_loop(&1, original_state))
    |> Enum.count(& &1)
  end
end

IO.inspect(MapComputer.count_unique_positions_visited("input/day6Test.txt") == 41)
IO.inspect(MapComputer.count_unique_positions_visited("input/day6.txt") == 5516)

IO.inspect(MapComputer.count_obstructions_which_cause_loop("input/day6Test.txt") == 6)
IO.inspect(MapComputer.count_obstructions_which_cause_loop("input/day6.txt") == 2008)
