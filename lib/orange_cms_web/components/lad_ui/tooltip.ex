defmodule OrangeCmsWeb.Components.LadUI.Tooltip do
  @moduledoc """
  Tooltip component


  ## Examples

      <.tooltip>
        <.link navigate={~p"/p"}>
          <.icon name="rocket-launch" class="w-5 h-5" />
        </.link>
        <.tooltip_content position="right">
          Projects
        </.tooltip_content>
      </.tooltip>
  """
  use OrangeCmsWeb.Components.LadUI, :component

  attr :class, :string, default: nil
  slot :inner_block, required: true
  attr :rest, :global

  def tooltip(assigns) do
    ~H"""
    <div class={["group relative", @class]} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  slot :inner_block, required: true
  attr :position, :string, values: ["top", "bottom", "left", "right"], default: "top"
  attr :rest, :global

  @postion_classes %{
    "top" => "bottom-full mb-4 left-1/2 -translate-x-1/2",
    "bottom" => "top-full mt-4 left-1/2 -translate-x-1/2",
    "left" => "right-full mr-4 top-1/2 -translate-y-1/2",
    "right" => "left-full ml-4 top-1/2 -translate-y-1/2"
  }
  def tooltip_content(assigns) do
    assigns = assign(assigns, class: @postion_classes[assigns.position])

    ~H"""
    <span
      class={[
        "absolute rounded bg-primary px-2 py-1 text-xs font-medium text-primary-foreground hidden group-hover:block",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </span>
    """
  end
end
