defmodule OrangeCmsWeb.Components.Display do
  @moduledoc """
  Some display utility component includes:

  - separator
  """
  use Phoenix.Component

  attr(:class, :string, default: nil)
  attr(:orientation, :string, values: ["horizontal", "vertical"], default: "horizontal")
  attr(:rest, :global)

  def separator(assigns) do
    class =
      if assigns.orientation == "vertical" do
        "h-full w-[1px]"
      else
        "h-[1px] w-full"
      end

    assigns = Map.put(assigns, :orientation_class, class)

    ~H"""
    <div role="none" class={["shrink-0 bg-border", @orientation_class, @class]}></div>
    """
  end

  @doc """
  Render avatar
  """

  attr(:class, :string, default: nil)
  slot(:inner_block, required: true)

  def avatar(assigns) do
    ~H"""
    <div class={["relative flex h-10 w-10 shrink-0 overflow-hidden rounded-full", @class]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr(:class, :string, default: nil)
  attr(:src, :string, required: true)
  attr(:rest, :global)

  def avatar_image(assigns) do
    ~H"""
    <img class={["aspect-square h-full w-full", @class]} src={@src} {@rest} />
    """
  end

  @doc """
  Render badge

  ## Examples

      <.badge>Published</.badge>
  """
  attr(:class, :string, default: "bg-primary text-primary-foreground hover:bg-primary/80")
  slot(:inner_block, required: true)
  attr(:rest, :global)

  def badge(assigns) do
    ~H"""
    <div
      class={[
        "inline-flex items-center rounded-md border px-2.5 py-0.5 text-xs font-semibold transition-colors focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 shadow border-transparent",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
