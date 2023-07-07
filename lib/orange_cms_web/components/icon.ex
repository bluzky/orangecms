defmodule OrangeCmsWeb.Components.Icon do
  @moduledoc false
  use Phoenix.Component

  @doc """
  Renders Heroicons
  """

  attr(:name, :string, required: true)
  attr(:class, :string, default: "w-5 h-5")
  attr(:solid, :boolean, default: false)
  attr(:rest, :global)

  def icon(assigns) do
    assigns = assigns |> Map.merge(assigns.rest) |> Map.delete(:rest)
    apply(Heroicons, :"#{String.replace(assigns.name, "-", "_")}", [assigns])
  end
end
