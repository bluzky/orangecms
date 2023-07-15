defmodule OrangeCmsWeb.Components.LadUI.Breadcrumb do
  @moduledoc false
  use OrangeCmsWeb.Components.LadUI, :component

  attr :class, :string, default: nil
  slot :inner_block, required: true
  attr :rest, :global

  def breadcrumb(assigns) do
    ~H"""
    <div class={[@class]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
