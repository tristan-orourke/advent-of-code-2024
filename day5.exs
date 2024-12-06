defmodule PrintQueue do
  def read_input(filename) do
    [rule_string, pages_string] =
      ReadInput.read_string(filename)
      |> String.split("\n\n")

    parse_rule = fn line ->
      String.trim(line) |> String.split("|") |> Enum.map(&String.to_integer/1) |> List.to_tuple()
    end

    parse_pages = fn line ->
      String.trim(line) |> String.split(",") |> Enum.map(&String.to_integer/1)
    end

    rules =
      rule_string
      |> String.split("\n")
      |> Enum.map(parse_rule)

    pages =
      pages_string
      |> String.split("\n")
      |> Enum.map(parse_pages)

    {rules, pages}
  end

  # Returns true if a comes before b in the list, or if one is not present
  def a_before_b_if_present?({a, b}, list) do
    a_index = Enum.find_index(list, &(&1 == a))
    b_index = Enum.find_index(list, &(&1 == b))
    a_index == nil or b_index == nil or a_index < b_index
  end

  def passes_all_rules?(rules, list) do
    rules |> Enum.all?(&a_before_b_if_present?(&1, list))
  end

  def middle_item(list) do
    list |> Enum.at(div(Enum.count(list), 2))
  end

  def sum_middle_of_correctly_sorted_pages(filename) do
    {rules, pages} = read_input(filename)

    Enum.filter(pages, &passes_all_rules?(rules, &1))
    |> Enum.map(&middle_item/1)
    |> Enum.sum()
  end

  def make_rule_sorter(rules) do
    fn a, b ->
      cond do
        Enum.any?(rules, fn {ra, rb} -> a == ra and b == rb end) -> true
        Enum.any?(rules, fn {ra, rb} -> a == rb and b == ra end) -> false
        # If we don't have a rule, assume they are equal value. For that, elixir sorter wants us to return true.
        true -> true
      end
    end
  end

  def sum_middle_of_incorrect_pages_after_sorting(filename) do
    {rules, pages} = read_input(filename)
    rule_sorter = make_rule_sorter(rules)

    Enum.filter(pages, &(not passes_all_rules?(rules, &1)))
    |> Enum.map(&Enum.sort(&1, rule_sorter))
    |> Enum.map(&middle_item/1)
    |> Enum.sum()
  end
end

# IO.inspect(PrintQueue.read_input("input/day5Test.txt"))
IO.inspect(PrintQueue.sum_middle_of_correctly_sorted_pages("input/day5Test.txt"))
IO.inspect(PrintQueue.sum_middle_of_correctly_sorted_pages("input/day5.txt"))

IO.inspect(PrintQueue.sum_middle_of_incorrect_pages_after_sorting("input/day5Test.txt"))
IO.inspect(PrintQueue.sum_middle_of_incorrect_pages_after_sorting("input/day5.txt"))
