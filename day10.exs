defmodule TopographicMap do
  @up {0, -1}
  @down {0, 1}
  @left {-1, 0}
  @right {1, 0}
  @directions [@up, @down, @left, @right]

  def find_trail_ends(position, matrix, acc \\ []) do
    height = Vectors.matrix_elem(matrix, position)

    case height do
      # If the position is out of bounds, this trail scores 0, an unsuccessful base case.
      nil ->
        acc

      # 9 is the end of the trail, and a successful base case.
      9 ->
        Enum.uniq([position | acc])

      _ ->
        Enum.map(@directions, &Vectors.add(position, &1))
        |> Enum.filter(&(Vectors.matrix_elem(matrix, &1) == height + 1))
        |> Stream.map(&find_trail_ends(&1, matrix, acc))
        |> Stream.concat()
        |> Enum.uniq()

        # |> Enum.sum()
        # |> Enum.reduce(acc, fn next_position, acc ->
        #   new_acc = score_trailhead(next_position, matrix, acc)
        #   %{new_acc | trails: Enum.map(acc.trails, &[position | &1])}
        # end)
    end
  end

  def score_trailhead(position, matrix) do
    find_trail_ends(position, matrix)
    |> Enum.count()
  end

  def rate_trailhead(position, matrix) do
    height = Vectors.matrix_elem(matrix, position)

    case height do
      # If the position is out of bounds, this trail scores 0, an unsuccessful base case.
      nil ->
        0

      # 9 is the end of the trail, and a successful base case.
      9 ->
        1

      _ ->
        Enum.map(@directions, &Vectors.add(position, &1))
        |> Enum.filter(&(Vectors.matrix_elem(matrix, &1) == height + 1))
        |> Stream.map(&rate_trailhead(&1, matrix))
        |> Enum.sum()
    end
  end

  def score_all_trailheads(filename) do
    matrix = ReadInput.read_integer_matrix(filename)

    Vectors.list_all_matrix_positions(matrix)
    |> Enum.filter(&(Vectors.matrix_elem!(matrix, &1) == 0))
    |> Enum.map(&score_trailhead(&1, matrix))
    |> Enum.sum()
  end

  def rate_all_trailheads(filename) do
    matrix = ReadInput.read_integer_matrix(filename)

    Vectors.list_all_matrix_positions(matrix)
    |> Enum.filter(&(Vectors.matrix_elem!(matrix, &1) == 0))
    |> Enum.map(&rate_trailhead(&1, matrix))
    |> Enum.sum()
  end
end

IO.inspect(TopographicMap.score_all_trailheads("input/day10Test.txt") == 36)
IO.inspect(TopographicMap.score_all_trailheads("input/day10.txt") == 811)

IO.inspect(TopographicMap.rate_all_trailheads("input/day10Test.txt") == 81)
IO.inspect(TopographicMap.rate_all_trailheads("input/day10.txt"))
