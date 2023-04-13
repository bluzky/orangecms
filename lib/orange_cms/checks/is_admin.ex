defmodule OrangeCms.Checks.IsAdmin do
  @moduledoc """
  This check is true if the user is_admin
  ```
  """
  use Ash.Policy.SimpleCheck

  @impl Ash.Policy.Check
  def describe(_) do
    "Check if actor is admin"
  end

  @impl Ash.Policy.SimpleCheck
  def match?(%{is_admin: true}, _context, _), do: true

  def match?(_, _, _), do: false
end
