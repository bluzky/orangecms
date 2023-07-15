defmodule OrangeCmsWeb.Components.LadUI.DropdownMenu do
  @moduledoc """
  Implement of dropdown menu components from
  https://ui.shadcn.com/docs/components/dropdown-menu

  """
  use OrangeCmsWeb.Components.LadUI, :component

  @doc """
  Render dropdown menu


  ## Examples:

   <.dropdown_menu>
   <.dropdown_menu_trigger>
   <.button variant="outline">Open</.button>
   </.dropdown_menu_trigger>
   <.dropdown_menu_content>
   <.dropdown_menu_label>Account</.dropdown_menu_label>
   <.dropdown_menu_separator />
   <.dropdown_menu_group>
   <.dropdown_menu_item>
       Profile
     <.dropdown_menu_shortcut>⌘P</.dropdown_menu_shortcut>
   </.dropdown_menu_item>
   <.dropdown_menu_item>
       Billing
     <.dropdown_menu_shortcut>⌘B</.dropdown_menu_shortcut>
   </.dropdown_menu_item>
   <.dropdown_menu_item>
       Settings
     <.dropdown_menu_shortcut>⌘S</.dropdown_menu_shortcut>
   </.dropdown_menu_item>
   </.dropdown_menu_group>
   </.dropdown_menu_content>
   </.dropdown_menu>
  """
  attr :class, :string, default: nil
  slot :inner_block, required: true
  attr :rest, :global

  def dropdown_menu(assigns) do
    ~H"""
    <div class={classes(["relative group inline-block", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :class, :string, default: nil
  slot :inner_block, required: true

  def dropdown_menu_trigger(assigns) do
    assigns = assign(assigns, id: "dropdown-#{:rand.uniform(999_999)}")

    ~H"""
    <div id={@id} phx-click={JS.toggle(to: "##{@id}+.dropdown-menu-content")}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :class, :string, default: "top-0 left-full"
  attr :hover_open, :boolean, default: false
  slot :inner_block, required: true
  attr :rest, :global

  def dropdown_menu_content(assigns) do
    ~H"""
    <div
      class={
        [
          "dropdown-menu-content hidden z-50 min-w-[8rem] w-56 overflow-hidden rounded-md border bg-popover p-1 text-popover-foreground shadow-md absolute",
          # (@hover_open && "group-hover:block"),
          @class
        ]
      }
      phx-click-away={JS.hide()}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :class, :string, default: nil
  slot :inner_block, required: true
  attr :rest, :global

  def dropdown_menu_label(assigns) do
    ~H"""
    <div class={classes(["px-2 py-1.5 text-sm font-semibold", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :class, :string, default: nil

  def dropdown_menu_separator(assigns) do
    ~H"""
    <div role="separator" aria-orientation="horizontal" class={classes(["-mx-1 my-1 h-px bg-muted", @class])}>
    </div>
    """
  end

  attr :class, :string, default: nil
  slot :inner_block, required: true
  attr :rest, :global

  def dropdown_menu_group(assigns) do
    ~H"""
    <div class={classes([@class])} role="group" {@rest}><%= render_slot(@inner_block) %></div>
    """
  end

  attr :class, :string, default: nil
  attr :disabled, :boolean, default: false
  slot :inner_block, required: true
  attr :rest, :global

  def dropdown_menu_item(assigns) do
    ~H"""
    <div
      class={classes([
        "relative flex cursor-default select-none items-center rounded-sm px-2 py-1.5 text-sm outline-none transition-colors hover:bg-accent hover:text-accent-foreground",
        @disabled && "pointer-events-none opacity-50",
        @class
      ])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :class, :string, default: nil
  slot :inner_block, required: true
  attr :rest, :global

  def dropdown_menu_shortcut(assigns) do
    ~H"""
    <span class={classes(["ml-auto text-xs tracking-widest opacity-60", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </span>
    """
  end
end
