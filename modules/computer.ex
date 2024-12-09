defmodule Computer do
  defmodule State do
    defstruct program: [], registers: %{}, output: []
  end

  # Interpreter should return its input, unchanged, when the program is finished.
  @spec run(Computer.State.t, (Computer.State.t -> Computer.State.t)) :: {:cont, Computer.State.t} | {:halt, Computer.State.t}
  def run(computer, interpreter) do
    case interpreter.(computer) do
      {:halt, new_computer} -> new_computer
      {:cont, ^computer} -> raise "Interpreter stalled without halting."
      {:cont, new_computer} -> run(new_computer, interpreter)
    end
  end

  def run(computer, interpreter, logger) do
    result = interpreter.(computer)
    logger.(result)
    case result do
      {:halt, new_computer} -> new_computer
      {:cont, ^computer} -> raise "Interpreter stalled without halting."
      {:cont, new_computer} -> run(new_computer, interpreter, logger)
    end
  end

end
