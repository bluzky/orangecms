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

       <.form_item field={@form[:repository]} label="Select your desired repo">
          <.select field={@form[:repository]} class="w-full">
            <.select_trigger {%{disabled: Enum.empty?(@repositories || [])}}>
              <.select_value placeholder="Select repository" />
            </.select_trigger>
            <.select_content>
              <.select_group>
                <.select_item
                  :for={item <- @repositories || []}
                  field={@form[:repository]}
                  value={item["full_name"]}
                >
                  <%= item["full_name"] %>
                </.select_item>
              </.select_group>
            </.select_content>
          </.select>
        </.form_item>
  """
  use Phoenix.Component

  alias OrangeCmsWeb.Components.ComponentHelpers
  alias Phoenix.LiveView.JS

  @doc """
  Ready to use select component with all required parts.
  """
  attr(:field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form, for example: @form[:email]")

  attr(:placeholder, :string, default: nil)
  attr(:disabled, :boolean, default: false)
  attr(:options, :list, required: true)
  attr(:value, :any, default: nil)
  attr(:default, :any, default: nil)
  attr(:phx_change, :any, default: nil)
  attr(:rest, :global)

  def simple_select(assigns) do
    ~H"""
    <.select field={@field} {@rest} default={@default} phx-change={@phx_change}>
      <.select_trigger {%{disabled: @disabled}}>
        <.select_value placeholder={@placeholder} />
      </.select_trigger>
      <.select_content>
        <.select_group>
          <.select_item
            :for={item <- @options}
            field={@field}
            value={item}
            selected={item == (@value || @default)}
          >
            <%= item %>
          </.select_item>
        </.select_group>
      </.select_content>
    </.select>
    """
  end

  attr(:id, :string, default: nil)
  attr(:name, :any)
  attr(:value, :any)

  attr(:field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form, for example: @form[:email]")

  attr(:default, :any, default: nil)
  attr(:class, :string, default: nil)
  attr(:phx_change, :any, default: nil)
  slot(:inner_block, required: true)
  attr(:rest, :global)

  def select(assigns) do
    assigns = ComponentHelpers.prepare_assign(assigns)
    assigns = assign(assigns, value: assigns[:value] || assigns[:default])

    ~H"""
    <div
      id={@id}
      class={["group relative inline-block", @class]}
      {@rest}
      data-name={assigns[:name]}
      phx-hook="shad-select"
    >
      <input
        type="hidden"
        id={"#{@id}-input"}
        name={assigns[:name]}
        value={assigns[:value] || @default}
        {%{"phx-change": @phx_change}}
      />
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
      <Heroicons.chevron_down class="w-4 h-4 opacity-50" />
    </button>
    """
  end

  attr(:placeholder, :string, default: nil)

  def select_value(assigns) do
    ~H"""
    <span
      id={"#{OrangeCmsWeb.Components.ComponentHelpers.generate_id()}__ignore_this_label__"}
      phx-update="ignore"
    >
      <span
        class="select-value pointer-events-none before:content-[attr(data-content)]"
        data-placeholder={@placeholder}
        data-content={@placeholder}
      >
      </span>
    </span>
    """
  end

  attr(:class, :string, default: nil)
  slot(:inner_block, required: true)
  attr(:rest, :global)

  def select_content(assigns) do
    ~H"""
    <div
      class={[
        "select-content hidden transition-all duration-150 ease-in-out absolute top-full mt-2 left-0 w-full z-50 min-w-[8rem] max-h-[285px] overflow-y-auto rounded-md border bg-popover text-popover-foreground shadow-md",
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

  attr(:name, :any)
  attr(:target, :string, default: nil, doc: "target is the id of parent select tag")

  attr(:field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form, for example: @form[:email]")

  attr(:value, :any, required: true)
  attr(:selected, :boolean, default: false)
  attr(:disabled, :boolean, default: false)
  attr(:class, :string, default: nil)
  slot(:inner_block, required: true)

  attr(:rest, :global)

  def select_item(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, target: field.id)
    |> assign_new(:name, fn ->
      if assigns[:multiple] == true,
        do: field.name <> "[]",
        else: field.name
    end)
    |> assign(:selected, field.value == assigns.value)
    |> select_item()
  end

  # Here I don't store value in the input's value attribute, because it will be submit to server
  # and increase request payload. Instead, I store it in data-value attribute, and use JS to update to input's value
  # I try using hidden radio directly but, phx-update event is not sent to server, because I use it to update display label
  # There are some logic for select here
  # 1. if click on item -> select item & close dropdown -> trigger phx-change event
  #
  # when input change by key navigation it trigger phx-click on label, this is so strange
  # so I created a absolute div and add phx-click event handler to make it work as expected
  def select_item(assigns) do
    ~H"""
    <% content = render_slot(@inner_block) %>
    <label
      role="option"
      class={[
        "select-item group relative flex w-full overflow-hidden cursor-default select-none items-center rounded-sm py-1.5 pl-8 pr-2 text-sm outline-none hover:bg-accent hover:text-accent-foreground  data-[disabled]:pointer-events-none data-[disabled]:opacity-50",
        @class
      ]}
      {%{"data-disabled": @disabled}}
      {@rest}
    >
      <input
        type="radio"
        name={"__hidden_#{@name}"}
        disabled={@disabled}
        checked={@selected}
        class="select-item peer sr-only"
        id={"#{@target}-#{String.replace(to_string(@value), " ", "-")}"}
        value=""
        data-value={@value}
        phx-change={%JS{}}
      />
      <div class="absolute top-0 left-0 w-full h-full peer-focus:bg-accent"></div>
      <span class="absolute left-2 flex h-3.5 w-3.5 items-center justify-center opacity-0 peer-checked:opacity-100">
        <Heroicons.check class="h-4 w-4" />
      </span>
      <span class="select-item-label z-0 peer-focus:text-accent-foreground"><%= content %></span>
      <div class="absolute top-0 left-0 w-full h-full" phx-click={select_value(@value, @target)}>
      </div>
    </label>
    """
  end

  def select_separator(assigns) do
    ~H"""
    <div class={["-mx-1 my-1 h-px bg-muted"]}></div>
    """
  end

  defp select_value(_value, _parent_id) do
    # JS.set_attribute({"value", value}, to: "##{parent_id}>input")
    # |> JS.set_attribute({"data-content", value}, to: "##{parent_id} .select-value")
    JS.dispatch("dismiss")
  end
end
