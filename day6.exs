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

  def position_in_matrix_range?({x, y}, matrix) do
    x >= 0 and y >= 0 and y < tuple_size(matrix) and x < tuple_size(elem(matrix, y))
  end

  def position_is_open?({x, y}, matrix) do
    matrix |> elem(y) |> elem(x) != "#"
  end

  def interpreter(
        %Computer.State{
          program: program,
          registers: %{position: position, direction: direction},
          output: output
        } = computer
      ) do
    test_position = Vectors.add(position, direction)

    cond do
      # If we're out of bounds, we're done. Return the computer unchanged.
      not position_in_matrix_range?(test_position, program) ->
        computer

      # If the position is open, move to it and add it to the output.
      position_is_open?(test_position, program) ->
        %Computer.State{
          computer
          | registers: %{computer.registers | position: test_position},
            output: [test_position | output]
        }

      # If the position is not open, turn right and continue.
      true ->
        %Computer.State{
          computer
          | registers: %{computer.registers | direction: turn_right(direction)}
        }
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
      output: [initial_position]
    }
  end

  def count_unique_positions_visited(input_file) do
    ReadInput.read_char_matrix(input_file)
    |> init()
    |> Computer.run(&interpreter/1)
    |> Map.get(:output)
    |> Enum.uniq()
    |> Enum.count()
  end
end

IO.inspect MapComputer.count_unique_positions_visited("input/day6Test.txt")
IO.inspect MapComputer.count_unique_positions_visited("input/day6.txt")
