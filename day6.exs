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

  def movement_interpreter(
        %Computer.State{
          program: program,
          registers: %{position: position, direction: direction},
          output: output
        } = computer
      ) do
    test_position = Vectors.add(position, direction)

    cond do
      # If we're out of bounds, we're done.
      not Vectors.position_in_matrix_range?(test_position, program) ->
        {:halt, computer}

      # If the position is open, move to it and add it to the output.
      position_is_open?(program, test_position) ->
        {:cont,
         %Computer.State{
           computer
           | registers: %{computer.registers | position: test_position},
             output: [%{position: test_position, direction: direction} | output]
         }}

      # If the position is not open, turn right and continue.
      true ->
        {:cont,
         %Computer.State{
           computer
           | registers: %{computer.registers | direction: turn_right(direction)}
         }}
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

  def init(char_matrix) do
    initial_position = find_position_in_matrix(char_matrix, "^")

    %Computer.State{
      program: char_matrix,
      registers: %{position: initial_position, direction: @up},
      output: [%{position: initial_position, direction: @up}]
    }
  end

  def count_unique_positions_visited(input_file) do
    ReadInput.read_char_matrix(input_file)
    |> init()
    |> Computer.run(&movement_interpreter/1)
    |> Map.get(:output)
    |> Enum.map(&Map.get(&1, :position))
    |> Enum.uniq()
    |> Enum.count()
  end

  def count_obstructions_which_cause_loop(input_file) do
    ReadInput.read_char_matrix(input_file)
    |> init()
    |> (fn c -> %Computer.State{c | output: %{test: "blah"}} end).()
  end
end

IO.inspect(MapComputer.count_unique_positions_visited("input/day6Test.txt"))
IO.inspect(MapComputer.count_unique_positions_visited("input/day6.txt"))

IO.inspect(MapComputer.count_obstructions_which_cause_loop("input/day6Test.txt"))
