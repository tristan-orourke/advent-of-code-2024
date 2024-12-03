defmodule Program do
  @mul ~r/(mul)\((\d{1,3}),(\d{1,3})\)/
  # @doCmd ~r/(do)\(\)/
  # @dontCmd ~r/(don't)\(\)/
  @programCmds ~r/(mul)\((\d{1,3}),(\d{1,3})\)|(do)\(\)|(don't)\(\)/

  def extract_muls(string) do
    Regex.scan(@mul, string, capture: :all_but_first)
  end

  def extract_cmds(string) do
    Regex.scan(@programCmds, string, capture: :all_but_first)
    |> Enum.map(fn m -> Enum.filter(m, &(&1 != "")) end)
  end

  def log(_, to_return) do
    to_return
  end

  def run_cmd(cmd) do
    case cmd do
      ["mul", val1, val2] -> log(cmd, String.to_integer(val1) * String.to_integer(val2))
      ["do"] -> log(cmd, 0)
      ["don't"] -> log(cmd, 0)
      _ -> log(cmd, 0)
    end
  end

  def init_machine(program) do
    %{enabled: true, program: program, output: []}
  end

  def run_program_step(machine) do
    %{enabled: enabled, program: [cmd | program], output: output} = machine
    case cmd do
      ["mul", val1, val2] -> %{enabled: enabled, program: program, output: if(enabled, do: [String.to_integer(val1) * String.to_integer(val2) | output], else: output)}
      ["do"] -> %{enabled: true, program: program, output: output}
      ["don't"] -> %{enabled: false, program: program, output: output}
    end
  end

  def run_program(machine) do
    %{program: program} = machine
    case program do
      [] -> machine
      _ -> run_program(run_program_step(machine))
    end
  end

  def sum_all_products(string) do
    extract_muls(string)
    |> Enum.map(&run_cmd/1)
    |> Enum.sum
  end

  def sum_all_enabled_products(string) do
    extract_cmds(string)
    |> init_machine
    |> run_program
    |> Map.get(:output)
    |> Enum.sum
  end
end

exampleInput = ReadInput.read_string(("input/day3Test.txt"))
realInput = ReadInput.read_string(("input/day3.txt"))

IO.inspect Program.sum_all_products(exampleInput)
IO.inspect Program.sum_all_products(realInput)

IO.inspect Program.sum_all_enabled_products(exampleInput)
IO.inspect Program.sum_all_enabled_products(realInput)
