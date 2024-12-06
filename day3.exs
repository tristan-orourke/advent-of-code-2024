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

  def run_cmd(cmd) do
    case cmd do
      ["mul", val1, val2] -> String.to_integer(val1) * String.to_integer(val2)
      ["do"] -> 0
      ["don't"] -> 0
      _ -> 0
    end
  end

  def init_machine(program) do
    %Computer.State{program: program, registers: %{enabled: true}}
  end

  def run_program_step(%Computer.State{program: []} = machine) do
    {:halt, machine}
  end

  def run_program_step(machine) do
    %{registers: %{enabled: enabled}, program: [cmd | program], output: output} = machine

    case cmd do
      ["mul", val1, val2] ->
        {:cont,
         %Computer.State{
           registers: %{enabled: enabled},
           program: program,
           output:
             if(enabled,
               do: [String.to_integer(val1) * String.to_integer(val2) | output],
               else: output
             )
         }}

      ["do"] ->
        {:cont, %Computer.State{registers: %{enabled: true}, program: program, output: output}}

      ["don't"] ->
        {:cont, %Computer.State{registers: %{enabled: false}, program: program, output: output}}
    end
  end

  def sum_all_products(string) do
    extract_muls(string)
    |> Enum.map(&run_cmd/1)
    |> Enum.sum()
  end

  def sum_all_enabled_products(string) do
    extract_cmds(string)
    |> init_machine
    |> Computer.run(&run_program_step/1)
    |> Map.get(:output)
    |> Enum.sum()
  end
end

exampleInput = ReadInput.read_string("input/day3Test.txt")
realInput = ReadInput.read_string("input/day3.txt")

IO.inspect(Program.sum_all_products(exampleInput))
IO.inspect(Program.sum_all_products(realInput))

IO.inspect(Program.sum_all_enabled_products(exampleInput))
IO.inspect(Program.sum_all_enabled_products(realInput))
