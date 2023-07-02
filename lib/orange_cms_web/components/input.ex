defmodule OrangeCmsWeb.Components.Input do
  @moduledoc """
  Implement of form component
  """
  use Phoenix.Component

  attr :id, :any, default: nil
  attr :name, :any
  attr :value, :any
  attr :type, :string,
    default: "text",
    values: ~w(date datetime-local email file hidden month number password
      tel text time url week)
    attr :field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form, for example: @form[:email]"
  attr :class, :string, default: nil
  attr :rest, :global

  def input(assigns) do
    assigns = prepare_assign(assigns)
    ~H"""
    <input
      class={[
        "flex h-10 w-full px-3 py-2 rounded-md border border-input bg-background text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:cursor-not-allowed disabled:opacity-50",
        @class
      ]}
      id={@id}
      type={@type}
      name={@name}
      value={@value}
      {@rest}
    />
    """
  end

  defp prepare_assign(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
      assigns
      |> assign(field: nil, id: assigns.id || field.id)
      |> assign_new(:name, fn -> if assigns[:multiple] == true, do: field.name <> "[]", else: field.name end)
      |> assign_new(:value, fn -> field.value end)
  end

  defp prepare_assign(assigns) do
    assigns
  end
end
