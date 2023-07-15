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
  attr :id, :any
  attr(:placeholder, :string, default: nil)
  attr(:disabled, :boolean, default: false)
  attr(:options, :list, required: true)
  attr(:value, :any)
  attr(:rest, :global)

  def simple_select(assigns) do
    assigns = ComponentHelpers.prepare_assign(assigns)

    ~H"""
    <.select {@rest} {Map.drop(assigns, [ :rest, :field, :options])}>
      <.select_trigger {%{disabled: @disabled}}>
        <.select_value placeholder={@placeholder} value={@value} />
      </.select_trigger>
      <.select_content>
        <.select_group>
          <.select_item
            :for={item <- @options}
            field={@field}
            value={item}
            name={@name}
            selected={item == @value}
          >
            <%= item %>
          </.select_item>
        </.select_group>
      </.select_content>
    </.select>
    """
  end

  attr(:id, :string, default: nil)
  attr(:name, :any, default: nil)
  attr(:value, :any, default: nil)
  attr(:class, :string, default: nil)
  attr(:"phx-change", :any, default: nil)
  slot(:inner_block, required: true)
  attr(:rest, :global)

  def select(assigns) do
    ~H"""
    <div
      id={@id}
      class={["select-root group/select relative inline-block", @class]}
      data-state="closed"
      close-select={JS.set_attribute({"data-state", "closed"})}
      select-change={JS.dispatch("select-change")}
      open-select={JS.set_attribute({"data-state", "open"}) |> JS.focus_first()}
      phx-hook="lad-select"
      {@rest}
    >
      <input
        type="text"
        class="hidden select-input"
        name={@name}
        value={@value}
        phx-change={assigns[:"phx-change"]}
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
        "select-trigger flex h-10 w-full items-center justify-between rounded-md border border-input bg-transparent px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus:outline-none focus:ring-1 focus:ring-ring disabled:cursor-not-allowed disabled:opacity-50",
        @class
      ]}
      phx-click={JS.dispatch("select-toggle")}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
      <Heroicons.chevron_down class="w-4 h-4 opacity-50" />
    </button>
    """
  end

  attr :value, :string, default: nil
  attr(:placeholder, :string, default: nil)

  def select_value(assigns) do
    ~H"""
    <span
      class="select-value pointer-events-none before:content-[attr(data-content)]"
      data-placeholder={@placeholder}
      data-content={@value || @placeholder}
    >
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
        "select-content hidden group-data-[state=open]/select:block transition-all duration-150 ease-in-out absolute top-full mt-2 left-0 w-full z-50 min-w-[8rem] max-h-[285px] overflow-y-auto rounded-md border bg-popover text-popover-foreground shadow-md",
        @class
      ]}
      {@rest}
    >
      <div class="p-1 w-full relative">
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

  attr(:value, :any, required: true)
  attr(:selected, :boolean, default: false)
  attr(:disabled, :boolean, default: false)
  attr(:class, :string, default: nil)
  slot(:inner_block, required: true)

  attr(:rest, :global)

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
        "select-item group/item relative flex w-full cursor-default select-none items-center rounded-sm py-1.5 pl-8 pr-2 text-sm outline-none focus:bg-accent focus:text-accent-foreground data-[disabled]:pointer-events-none data-[disabled]:opacity-50",
        @class
      ]}
      {%{"data-disabled": @disabled}}
      phx-click={JS.dispatch("select-change")}
      data-selected={@selected && "true"}
      data-value={@value}
      {@rest}
    >
      <div class="absolute top-0 left-0 w-full h-full group-data-[focus=true]/item:bg-accent group-hover/item:bg-accent">
      </div>
      <span class="absolute left-2 flex h-3.5 w-3.5 items-center justify-center opacity-0 group-data-[selected=true]/item:opacity-100">
        <Heroicons.check class="h-4 w-4" />
      </span>
      <span class="select-item-label z-0 peer-focus:text-accent-foreground"><%= content %></span>
    </label>
    """
  end

  def select_separator(assigns) do
    ~H"""
    <div class={["-mx-1 my-1 h-px bg-muted"]}></div>
    """
  end
end
