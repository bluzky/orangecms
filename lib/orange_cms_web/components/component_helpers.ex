defmodule OrangeCmsWeb.Components.ComponentHelpers do
  @moduledoc false
  import Phoenix.Component

  @doc """
  Prepare input assigns for use in a form. Extract required attribute from the Form.Field struct and update current assigns.
  """
  def prepare_assign(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil)
    |> assign_new(:id, fn -> field.id end)
    |> assign_new(:name, fn ->
      if assigns[:multiple] == true,
        do: field.name <> "[]",
        else: field.name
    end)
    |> assign_new(:value, fn -> field.value end)
  end

  def prepare_assign(assigns) do
    assigns
  end

  @doc """
  Generate a unique id for a component with given prefix

  Options:

      * `:prefix` - prefix for the generated id
  """
  def generate_id(opts \\ []) do
    999_999
    |> :rand.uniform()
    |> to_string()
    |> Base.encode32(case: :lower, padding: false)
    |> String.replace_prefix("", opts[:prefix] || "")
  end
end
