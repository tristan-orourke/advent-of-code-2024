defmodule ReadInput do
  def rotateMatrix(matrix) do
    Enum.zip_with(matrix, &Function.identity/1)
  end

  def nestedMap(matrix, fun) do
    Enum.map(matrix, &(Enum.map(&1, fun)))
  end

  def readVerticalLists(filename) do
    File.read!(filename)
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.split/1)
    |> nestedMap(&String.to_integer/1)
    |> rotateMatrix
  end

  def readReports(filename) do
    File.read!(filename)
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.split/1)
    |> nestedMap(&String.to_integer/1)
  end
end

# IO.inspect ReadInput.readVerticalLists("input/day1Test.txt")
