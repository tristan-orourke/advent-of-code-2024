defmodule Crossword do
  @directions [{-1, -1}, {0, -1}, {1, -1},
               {-1, 0}, {1, 0},
               {-1, 1}, {0, 1}, {1, 1}]
  @four_corners [{-1,-1}, {1,-1}, {-1,1}, {1,1}]
  @first_diagonal [{-1,-1}, {0,0}, {1,1}]
  @second_diagonal [{1,-1}, {0,0}, {-1,1}]

  def word_in_direction?(_, "", _, _), do: true
  def word_in_direction?(matrix, word, position, direction) do
    cond do
      !Vectors.position_in_matrix_range?(position, matrix) -> false
      Vectors.matrix_elem(matrix, position) != String.at(word, 0) -> false
      true -> word_in_direction?(matrix, String.slice(word, 1..-1//1), Vectors.add(position, direction), direction)
    end
  end


  def count_words_in_crossword(matrix, word) do
    start_char = String.at(word, 0)
    Vectors.list_all_matrix_positions(matrix)
    |> Enum.filter(fn position -> Vectors.matrix_elem(matrix, position) == start_char end)
    |> Enum.map(fn position -> Enum.count(@directions, fn direction -> word_in_direction?(matrix, word, position, direction) end) end)
    |> Enum.sum
  end
  def get_word(positions, matrix) do
    Enum.map(positions, fn position -> Vectors.matrix_elem(matrix, position) end) |> Enum.join
  end
  def position_is_x_max?(position, matrix) do
    four_positions = Enum.map(@four_corners, fn direction -> Vectors.add(position, direction) end)
    in_bounds = Enum.all?(four_positions, fn position -> Vectors.position_in_matrix_range?(position, matrix) end)
    if !in_bounds do
      false
    else
      word1 = Enum.map(@first_diagonal, fn direction -> Vectors.add(position, direction) end) |> get_word(matrix)
      word2 = Enum.map(@second_diagonal, fn direction -> Vectors.add(position, direction) end) |> get_word(matrix)
      (word1 == "MAS" or word1 == "SAM") and (word2 == "MAS" or word2 == "SAM")
    end
  end
  def count_x_mas_in_crossword(matrix) do
    Vectors.list_all_matrix_positions(matrix)
      |> Enum.filter(fn position -> Vectors.matrix_elem(matrix, position) == "A" end)
      |> Enum.count(fn position -> position_is_x_max?(position, matrix) end)
  end
end


# IO.inspect ReadInput.read_char_matrix("input/day4Test.txt")
IO.inspect Crossword.count_words_in_crossword(ReadInput.read_char_matrix("input/day4Test.txt"), "XMAS")
IO.inspect Crossword.count_words_in_crossword(ReadInput.read_char_matrix("input/day4.txt"), "XMAS")

IO.inspect Crossword.count_x_mas_in_crossword(ReadInput.read_char_matrix("input/day4Test.txt"))
IO.inspect Crossword.count_x_mas_in_crossword(ReadInput.read_char_matrix("input/day4.txt"))
