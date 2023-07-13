defmodule OrangeCmsWeb.Components.Collapsible do
  @moduledoc """
  Collapsible component https://ui.shadcn.com/docs/components/collapsible

  ## Examples

      <.collapsible id="test" open class="w-[350px] space-y-2">
          <div class="flex items-center justify-between space-x-4 px-4">
            <h4 class="text-sm font-semibold">
              @peduarte starred 3 repositories
            </h4>
            <.collapsible_trigger root="test">
              <.button variant="ghost" class=" p-0">
                <Heroicons.chevron_up_down class="h-4 w-4" />
                <span class="sr-only">toggle</span>
              </.button>
            </.collapsible_trigger>
          </div>
          <div class="rounded-md border px-4 py-3 font-mono text-sm">
            @radix-ui/primitives
          </div>
          <.collapsible_content class="space-y-2">
            <div class="rounded-md border px-4 py-3 font-mono text-sm">
              @radix-ui/colors
            </div>
            <div class="rounded-md border px-4 py-3 font-mono text-sm">
              @stitches/react
            </div>
          </.collapsible_content>
        </.collapsible>
  """
  use Phoenix.Component

  alias OrangeCmsWeb.Components.LadJS

  attr :open, :boolean, default: false, doc: "Whether the collapsible is open or not"
  attr(:class, :string, default: nil)
  slot(:inner_block, required: true)
  attr(:rest, :global)

  def collapsible(assigns) do
    ~H"""
    <div class={["group collapsible-root", @class]} {@rest} data-state={(@open && "open") || "closed"}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :root, :string, required: true, doc: "The id of the root collapsible"
  attr(:class, :string, default: "inline-block")
  slot(:inner_block, required: true)
  attr(:rest, :global)

  def collapsible_trigger(assigns) do
    ~H"""
    <div
      class={["relative", @class]}
      {@rest}
      phx-click={
        LadJS.toggle_attribute({"data-state", {"open", "closed"}}, to: "closest(.collapsible-root)")
      }
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr(:class, :string, default: nil)
  slot(:inner_block, required: true)
  attr(:rest, :global)

  def collapsible_content(assigns) do
    ~H"""
    <div
      class={[
        "transition ease-in-out duration-3000 opacity-0 h-0 -translate-y-1/4 overflow-hidden group-data-[state=open]:opacity-100 group-data-[state=open]:h-auto group-data-[state=open]:overflow-visible group-data-[state=open]:-translate-y-0",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
