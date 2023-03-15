defmodule OrangeCms.Shared.Nanoid do
  @moduledoc "Generate short id using nanoid"

  @doc "Generates a new uuid"
  def generate do
    Nanoid.generate(10)
  end
end
