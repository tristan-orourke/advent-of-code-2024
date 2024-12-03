defmodule Program do
  @mul ~r/(?<cmd>mul)\((?<val1>\d{1,3}),(?<val2>\d{1,3})\)/

  def named_captures(regex, string, options \\ []) when is_binary(string) do
    names = Regex.names(regex)
    options = Keyword.put(options, :capture, names)

    regex
    |> Regex.scan(string, options)
    |> Enum.map(fn result -> Enum.zip(names, result) |> Enum.into(%{}) end)
  end

  def extract_muls(string) do
    named_captures(@mul, string)
  end

  def run_cmd(cmd) do
    case cmd do
      %{"cmd" => "mul", "val1" => val1, "val2" => val2} -> String.to_integer(val1) * String.to_integer(val2)
    end
  end

  def sum_all_products(string) do
    extract_muls(string)
    |> Enum.map(&run_cmd/1)
    |> Enum.sum
  end


end

exampleInput = ReadInput.readString(("input/day3Test.txt"))
realInput = ReadInput.readString(("input/day3.txt"))

IO.inspect Program.sum_all_products(exampleInput)
IO.inspect Program.sum_all_products(realInput)
