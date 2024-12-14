defmodule Vectors do
  # Assuming a vector is a tuple of integers.
  def sum(vectors) do
    vectors
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.zip_with(&Enum.sum/1)
    |> List.to_tuple()
  end

  def add(a, b) do
    sum([a, b])
  end

  def scale(vector, scalar) do
    vector
    |> Tuple.to_list()
    |> Enum.map(&(&1 * scalar))
    |> List.to_tuple()
  end

  def subtract(a, b) do
    sum([a, scale(b, -1)])
  end

  def position_in_matrix_range?({x, y}, matrix) do
    x >= 0 and y >= 0 and y < tuple_size(matrix) and x < tuple_size(elem(matrix, y))
  end

  def matrix_elem!(matrix, {x, y}) do
    matrix |> elem(y) |> elem(x)
  end

  def matrix_elem(matrix, {x, y}) do
    if position_in_matrix_range?({x, y}, matrix) do
      matrix_elem!(matrix, {x, y})
    else
      nil
    end
  end

  def list_all_matrix_positions(matrix) do
    height = tuple_size(matrix)
    width = tuple_size(elem(matrix, 0))
    for y <- 0..(height - 1), x <- 0..(width - 1), do: {x, y}
  end

  def matrix_put_elem(matrix, {x, y}, elem) do
    put_elem(
      matrix,
      y,
      put_elem(elem(matrix, y), x, elem)
    )
  end
end
