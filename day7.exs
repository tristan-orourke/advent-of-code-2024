defmodule EquationCalibration do
  def can_make_target?([number], target), do: number == target

  def can_make_target?([a | rest], target) do
    [b | rest] = rest
    can_make_target?([a + b | rest], target) or can_make_target?([a * b | rest], target)
  end

  def can_make_target_with_concat?([number], target), do: number == target

  def can_make_target_with_concat?([a | rest], target) do
    [b | rest] = rest

    can_make_target_with_concat?([concat_numbers(a, b) | rest], target) or
      can_make_target_with_concat?([a + b | rest], target) or
      can_make_target_with_concat?([a * b | rest], target)
  end

  def concat_numbers(a, b) do
    (to_string(a) <> to_string(b)) |> String.to_integer()
  end

  def parse_input(filename) do
    ReadInput.read_lines(filename)
    |> Enum.map(&String.split(&1, [" ", ":"], trim: true))
    |> Enum.map(&Enum.map(&1, fn x -> String.to_integer(x) end))
  end

  def sum_valid_equations(filename) do
    parse_input(filename)
    |> Enum.filter(fn [target | numbers] -> can_make_target?(numbers, target) end)
    |> Enum.map(&hd/1)
    |> Enum.sum()
  end

  def sum_valid_equations_with_concat(filename) do
    parse_input(filename)
    |> Enum.filter(fn [target | numbers] -> can_make_target_with_concat?(numbers, target) end)
    |> Enum.map(&hd/1)
    |> Enum.sum()
  end


end

IO.inspect(EquationCalibration.sum_valid_equations("input/day7Test.txt") == 3749)
IO.inspect(EquationCalibration.sum_valid_equations("input/day7.txt") == 4555081946288)

IO.inspect(EquationCalibration.sum_valid_equations_with_concat("input/day7Test.txt") == 11387)
IO.inspect(EquationCalibration.sum_valid_equations_with_concat("input/day7.txt") == 227921760109726)
