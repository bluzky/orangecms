defmodule OrangeCmsWeb.Components.LadUI.Input do
  @moduledoc """
  Implement of form component
  """
  use OrangeCmsWeb.Components.LadUI, :component

  attr(:id, :any, default: nil)
  attr(:name, :any)
  attr(:value, :any)

  attr(:type, :string,
    default: "text",
    values: ~w(date datetime-local email file hidden month number password
      tel text time url week)
  )

  attr(:field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form, for example: @form[:email]")

  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def input(assigns) do
    assigns = prepare_assign(assigns)

    ~H"""
    <input
      class={
        classes([
          "flex h-10 w-full px-3 py-2 rounded-md border border-input bg-background text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:cursor-not-allowed disabled:opacity-50",
          @class
        ])
      }
      id={@id}
      type={@type}
      name={@name}
      value={@value}
      {@rest}
    />
    """
  end

  @doc """
  Implement textarea component

  If a form field is provided, value is used from the form field, otherwise `inner_block` is used as the value.

  ## Examples

      <.textarea field={@form[:name]} class="h-32">My content</.textarea>
  """
  attr(:id, :any, default: nil)
  attr(:name, :any)
  attr(:value, :any)
  attr(:field, Phoenix.HTML.FormField)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def textarea(assigns) do
    assigns = prepare_assign(assigns)

    ~H"""
    <textarea
      class={
        classes([
          "flex min-h-[80px] w-full px-3 py-2 rounded-md border border-input bg-transparent text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:cursor-not-allowed disabled:opacity-50",
          @class
        ])
      }
      id={@id}
      name={@name}
      {@rest}
    ><%= Phoenix.HTML.Form.normalize_value("textarea", @value) %></textarea>
    """
  end

  @doc """
  Implement checkbox input component

  ## Examples:

      <.checkbox field={@form[:remember_me]} />
      <.checkbox class="!border-destructive" name="agree" value={true} />
  """
  attr(:id, :any, default: nil)
  attr(:name, :any, default: nil)
  attr(:value, :any, default: nil)
  attr(:field, Phoenix.HTML.FormField)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def checkbox(assigns) do
    assigns =
      assigns
      |> prepare_assign()
      |> assign_new(:checked, fn ->
        Phoenix.HTML.Form.normalize_value("checkbox", assigns.value)
      end)

    ~H"""
    <input type="hidden" name={@name} value="false" />
    <input
      type="checkbox"
      class={
        classes([
          "peer h-4 w-4 shrink-0 rounded-sm border border-primary shadow focus:ring-0 focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:cursor-not-allowed disabled:opacity-50 text-primary",
          @class
        ])
      }
      id={@id || @name}
      name={@name}
      value="true"
      checked={@checked}
      {@rest}
    />
    """
  end

  @doc """
  Implement switch input checkbox

  ## Examples:

      <.switch field={@form[:remember_me]} />

      <div class="flex items-center space-x-2">
        <.switch id="airplane-mode" />
        <.label for="airplane-mode">Airplane Mode</.label>
      </div>
  """
  attr(:id, :any, default: nil)
  attr(:name, :any, default: nil)
  attr(:value, :any, default: nil)
  attr(:field, Phoenix.HTML.FormField)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def switch(assigns) do
    assigns =
      assigns
      |> prepare_assign()
      |> assign_new(:checked, fn ->
        Phoenix.HTML.Form.normalize_value("checkbox", assigns.value)
      end)

    ~H"""
    <label
      class={classes(["relative inline-flex items-center p-0.5 h-[24px] w-[44px]", @class])}
      {@rest}
    >
      <input type="hidden" name={@name} value="false" />
      <input
        type="checkbox"
        id={@id || @name}
        name={@name}
        value="true"
        checked={@checked}
        class="peer sr-only"
      />
      <span class="bg-input absolute inset-0 shrink-0 cursor-pointer rounded-full transition-colors disabled:cursor-not-allowed disabled:opacity-50 peer-checked:bg-primary">
      </span>
      <span class="bg-background pointer-events-none block h-5 w-5 translate-x-0 rounded-full shadow-lg ring-0 transition-transform peer-checked:translate-x-5">
      </span>
    </label>
    """
  end
end
