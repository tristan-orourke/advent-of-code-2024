defmodule Computer do
  defmodule State do
    defstruct program: [], registers: %{}, output: []
  end

  # Interpreter should return its input, unchanged, when the program is finished.
  @spec run(Computer.State.t, (Computer.State.t -> Computer.State.t)) :: Computer.State.t
  def run(computer, interpreter) do
    next = interpreter.(computer)

    if next == computer do
      computer
    else
      run(next, interpreter)
    end
  end

  def run(computer, interpreter, logger) do
    logger.(computer)
    next = interpreter.(computer)

    if next == computer do
      computer
    else
      run(next, interpreter, logger)
    end
  end
end
