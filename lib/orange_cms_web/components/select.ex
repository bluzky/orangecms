defmodule OrangeCmsWeb.Components.Select do
  @moduledoc """
  Implement of select components from https://ui.shadcn.com/docs/components/select
  This component require javascript to work properly.

  Read more in assets/js/componentHooks.js


  ## Examples:

      <form>
         <.select default="banana" id="fruit-select">
            <.select_trigger class="w-[180px]">
              <.select_value placeholder=".select a fruit"/>
            </.select_trigger>
            <.select_content>
              <.select_group>
                <.select_label>Fruits</.select_label>
                <.select_item name="fruit" value="apple">Apple</.select_item>
                <.select_item name="fruit" value="banana">Banana</.select_item>
                <.select_item name="fruit" value="blueberry">Blueberry</.select_item>
                <.select_separator />
                <.select_item  name="fruit" disabled value="grapes">Grapes</.select_item>
                <.select_item  name="fruit" value="pineapple">Pineapple</.select_item>
              </.select_group>
        </.select_content>
          </.select>

        <.button type="submit">Submit</.button>
      </form>


  ## Examples with form field:

      <.select id="type-select" class="w-full">
        <.select_trigger class="w-full">
            <.select_value placeholder="Select project type" />
        </.select_trigger>
        <.select_content>
            <.select_group>
                <.select_label>Project type</.select_label>
                <.select_item :for={type <- ["github", "headless_cms" ]} name="fruit" value={type}><%= type %></.select_item>
            </.select_group>
        </.select_content>
      </.select>
  """
  use Phoenix.Component
  alias Phoenix.LiveView.JS
  alias OrangeCmsWeb.Components.ComponentHelpers

  attr(:id, :string, required: true)
  attr(:name, :any)
  attr(:value, :any)

  attr(:field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"
  )

  attr(:default, :any, default: nil)
  attr(:class, :string, default: nil)
  slot(:inner_block, required: true)
  attr(:rest, :global)

  def select(assigns) do
    assigns = ComponentHelpers.prepare_assign(assigns)
    assigns = assign(assigns, :value, assigns[:value] || assigns[:default])

    ~H"""
    <div
      id={@id}
      class={["relative inline-block", @class]} {@rest}
      data-value={assigns[:value]}
      data-name={assigns[:name]}
      phx-hook="shad-select"
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr(:class, :string, default: nil)
  slot(:inner_block, required: true)
  attr(:rest, :global)

  def select_trigger(assigns) do
    ~H"""
    <button
      type="button"
      class={[
        "select-trigger flex h-10 w-full px-3 py-2 items-center justify-between rounded-md border border-input bg-transparent text-sm ring-offset-background placeholder:text-muted-foreground focus:outline-none focus:ring-1 focus:ring-ring disabled:cursor-not-allowed disabled:opacity-50",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  attr(:placeholder, :string, default: nil)

  def select_value(assigns) do
    ~H"""
    <span class="select-value pointer-events-none before:content-[attr(data-content)]" phx-update="ignore" id={"select-value-#{:rand.uniform(999999)}"}><%= @placeholder %></span>
    """
  end

  attr(:class, :string, default: nil)
  slot(:inner_block, required: true)
  attr(:rest, :global)

  def select_content(assigns) do
    ~H"""
    <div
      class={[
        "select-content hidden transition-all absolute top-full mt-2 left-0 w-full z-50 min-w-[8rem] overflow-hidden rounded-md border bg-popover text-popover-foreground shadow-md data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95 data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2 data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2 data-[side=bottom]:translate-y-1 data-[side=left]:-translate-x-1 data-[side=right]:translate-x-1 data-[side=top]:-translate-y-1",
        @class
      ]}
      {@rest}
      phx-click-away={JS.dispatch("dismiss")}
    >
      <div class="p-1 w-full">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  attr(:class, :string, default: nil)
  slot(:inner_block, required: true)
  attr(:rest, :global)

  def select_group(assigns) do
    ~H"""
    <div role="group" class={[@class]} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr(:class, :string, default: nil)
  slot(:inner_block, required: true)
  attr(:rest, :global)

  def select_label(assigns) do
    ~H"""
    <div class={["py-1.5 pl-8 pr-2 text-sm font-semibold", @class]} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr(:name, :string, default: nil)
  attr(:value, :any, default: nil)
  attr(:checked, :boolean, default: false)
  attr(:disabled, :boolean, default: false)
  attr(:class, :string, default: nil)
  slot(:inner_block, required: true)

  attr(:rest, :global)

  def select_item(assigns) do
    ~H"""
    <label
      role="option"
      class={[
        "group relative flex w-full overflow-hidden cursor-default select-none items-center rounded-sm py-1.5 pl-8 pr-2 text-sm outline-none hover:bg-accent hover:text-accent-foreground  data-[disabled]:pointer-events-none data-[disabled]:opacity-50",
        @class
      ]}
      {%{"data-disabled": @disabled}}
      {@rest}
    >
      <input type="radio" name={@name} disabled={@disabled} checked={@checked}
        class="select-item peer sr-only" value={@value}
        id={@value}
      />
      <div class="absolute top-0 left-0 w-full h-full peer-focus:bg-accent"></div>
      <span class="absolute left-2 flex h-3.5 w-3.5 items-center justify-center opacity-0 peer-checked:opacity-100">
        <Heroicons.check class="h-4 w-4" />
      </span>
      <span class="select-item-label z-0 peer-focus:text-accent-foreground"><%= render_slot(@inner_block) %></span>
    </label>
    """
  end

  def select_separator(assigns) do
    ~H"""
    <div class={["-mx-1 my-1 h-px bg-muted"]}></div>
    """
  end
end
