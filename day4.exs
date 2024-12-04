defmodule Crossword do
  @directions [{-1, -1}, {0, -1}, {1, -1},
               {-1, 0}, {1, 0},
               {-1, 1}, {0, 1}, {1, 1}]
  @four_corners [{-1,-1}, {1,-1}, {-1,1}, {1,1}]
  @first_diagonal [{-1,-1}, {0,0}, {1,1}]
  @second_diagonal [{1,-1}, {0,0}, {-1,1}]

  def position_in_matrix_range?({x, y}, matrix) do
    x >= 0 and y >= 0 and y < tuple_size(matrix) and x < tuple_size(elem(matrix, y))
  end
  def matrix_elem(matrix, {x, y}) do
    matrix |> elem(y) |> elem(x)
  end

  def add_vectors({x1,y1}, {x2,y2}) do
    {x1 + x2, y1 + y2}
    # Enum.zip(Tuple.to_list(p1), Tuple.to_list(p2), &Enum.sum/1) |> List.to_tuple
  end

  def word_in_direction?(_, "", _, _), do: true
  def word_in_direction?(matrix, word, position, direction) do
    cond do
      !position_in_matrix_range?(position, matrix) -> false
      matrix_elem(matrix, position) != String.at(word, 0) -> false
      true -> word_in_direction?(matrix, String.slice(word, 1..-1//1), add_vectors(position, direction), direction)
    end
  end

  def list_all_positions(matrix) do
    height = tuple_size(matrix)
    width = tuple_size(elem(matrix, 0))
    for y <- 0..height - 1, x <- 0..width - 1, do: {x, y}
  end
  def count_words_in_crossword(matrix, word) do
    start_char = String.at(word, 0)
    list_all_positions(matrix)
    |> Enum.filter(fn position -> matrix_elem(matrix, position) == start_char end)
    |> Enum.map(fn position -> Enum.count(@directions, fn direction -> word_in_direction?(matrix, word, position, direction) end) end)
    |> Enum.sum
  end
  def get_word(positions, matrix) do
    Enum.map(positions, fn position -> matrix_elem(matrix, position) end) |> Enum.join
  end
  def position_is_x_max?(position, matrix) do
    four_positions = Enum.map(@four_corners, fn direction -> add_vectors(position, direction) end)
    in_bounds = Enum.all?(four_positions, fn position -> position_in_matrix_range?(position, matrix) end)
    if !in_bounds do
      false
    else
      word1 = Enum.map(@first_diagonal, fn direction -> add_vectors(position, direction) end) |> get_word(matrix)
      word2 = Enum.map(@second_diagonal, fn direction -> add_vectors(position, direction) end) |> get_word(matrix)
      (word1 == "MAS" or word1 == "SAM") and (word2 == "MAS" or word2 == "SAM")
    end
  end
  def count_x_mas_in_crossword(matrix) do
    list_all_positions(matrix)
      |> Enum.filter(fn position -> matrix_elem(matrix, position) == "A" end)
      |> Enum.count(fn position -> position_is_x_max?(position, matrix) end)
  end
end


# IO.inspect ReadInput.read_char_matrix("input/day4Test.txt")
IO.inspect Crossword.count_words_in_crossword(ReadInput.read_char_matrix("input/day4Test.txt"), "XMAS")
IO.inspect Crossword.count_words_in_crossword(ReadInput.read_char_matrix("input/day4.txt"), "XMAS")

IO.inspect Crossword.count_x_mas_in_crossword(ReadInput.read_char_matrix("input/day4Test.txt"))
IO.inspect Crossword.count_x_mas_in_crossword(ReadInput.read_char_matrix("input/day4.txt"))
