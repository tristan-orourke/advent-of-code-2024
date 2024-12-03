defmodule ReadInput do
  def rotate_matrix(matrix) do
    Enum.zip_with(matrix, &Function.identity/1)
  end

  def nested_map(matrix, fun) do
    Enum.map(matrix, &(Enum.map(&1, fun)))
  end

  def read_vertical_lists(filename) do
    File.read!(filename)
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.split/1)
    |> nested_map(&String.to_integer/1)
    |> rotate_matrix
  end

  def read_number_lists(filename) do
    File.read!(filename)
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.split/1)
    |> nested_map(&String.to_integer/1)
  end

  def read_string(filename) do
    File.read!(filename)
    |> String.trim
  end
end

# IO.inspect ReadInput.read_vertical_lists("input/day1Test.txt")
