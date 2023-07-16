defmodule OrangeCmsWeb.Components.LadUI.Button do
  @moduledoc false
  use OrangeCmsWeb.Components.LadUI, :component

  import OrangeCmsWeb.Components.LadUI.Icon

  @doc """
  Renders a button.

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go" class="ml-2">Send!</.button>
  """
  attr(:type, :string, default: nil)
  attr(:class, :string, default: nil)

  attr(:variant, :string,
    values: ~w(primary secondary destructive outline ghost link),
    default: "primary",
    doc: "the button variant style"
  )

  attr(:size, :string, values: ~w(default sm lg icon), default: "default")
  attr(:icon, :string, default: nil)
  attr(:icon_right, :string, default: nil)
  attr(:rest, :global, include: ~w(disabled form name value))

  slot(:inner_block, required: true)

  def(button(assigns)) do
    assigns = assign(assigns, :variant_class, button_variant(assigns.variant, assigns.size))

    ~H"""
    <button
      type={@type}
      class={classes([
        "inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50",
        @variant_class,
        "gap-1",
        "phx-submit-loading:opacity-75 btn",
        @class
      ])}
      {@rest}
    >
      <.icon :if={not is_nil(@icon)} name={@icon} class="h-4 w-4" />
      <%= render_slot(@inner_block) %>
      <.icon :if={not is_nil(@icon_right)} name={@icon_right} class="h-4 w-4" />
    </button>
    """
  end

  @button_variants %{
    "primary" => "bg-primary text-primary-foreground hover:bg-primary/90",
    "secondary" => "bg-secondary text-secondary-foreground hover:bg-secondary/80",
    "destructive" => "bg-destructive text-destructive-foreground hover:bg-destructive/90",
    "outline" => "border border-input bg-background shadow-sm hover:bg-accent hover:text-accent-foreground",
    "ghost" => "hover:bg-accent hover:text-accent-foreground",
    "link" => "text-primary underline-offset-4 hover:underline"
  }

  @button_sizes %{
    "default" => "h-10 px-4 py-2",
    "sm" => "h-9 rounded-md px-3",
    "lg" => "h-11 rounded-md px-8",
    "icon" => "h-10 w-10"
  }
  def button_variant(variant \\ "primary", size \\ "default") do
    Enum.join([@button_variants[variant], @button_sizes[size]], " ")
  end
end
