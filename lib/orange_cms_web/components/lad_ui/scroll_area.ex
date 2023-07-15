defmodule OrangeCmsWeb.Components.LadUI.ScrollArea do
  @moduledoc false
  use OrangeCmsWeb.Components.LadUI, :component

  attr :class, :string, default: nil
  attr(:rest, :global)
  slot :inner_block, required: true

  def scroll_area(assigns) do
    ~H"""
    <div class={["relative overflow-hidden", @class]} {@rest}>
      <style>
            /* Firefox */
        [data-scroll-area] {
        scrollbar-width: thin;
          scrollbar-color: #c2c2c2 transparent;
        }

        /* Chrome, Edge, and Safari */
        [data-scroll-area]::-webkit-scrollbar {
        width: 12px;
        }

        [data-scroll-area]::-webkit-scrollbar-track {
        background: transparent;
        border-radius: 5px;
        }

        [data-scroll-area]::-webkit-scrollbar-thumb {
        background-color: #c2c2c2;
        border-radius: 14px;
        border: 2px solid var(--background);
        }
          
      </style>
      <div
        data-scroll-area=""
        class="rounded-[inherit] h-full w-full overflow-y-auto overflow-x-hidden"
      >
        <div style="min-width: 100%; display: table;">
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    </div>
    """
  end
end
