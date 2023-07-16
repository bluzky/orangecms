defmodule OrangeCmsWeb.Components.LadUI.Alert do
  @moduledoc false
  use OrangeCmsWeb.Components.LadUI, :component

  import OrangeCmsWeb.Components.LadUI.Icon

  @doc """
  Render alert
  """

  attr(:kind, :any, default: nil)
  attr(:icon, :string, default: nil)
  attr(:class, :string, default: nil)
  slot(:inner_block, required: true)
  attr(:rest, :global, default: %{})

  def alert(assigns) do
    assigns = assign(assigns, kind: to_string(assigns.kind))

    assigns =
      if is_nil(assigns[:icon]) do
        icon =
          case to_string(assigns.kind) do
            "success" -> "check-circle"
            "info" -> "information_circle"
            "error" -> "exclamation_triangle"
            _ -> nil
          end

        assign(assigns, :icon, icon)
      else
        assigns
      end

    # We have to specify full class name for tailwind to extract class name
    ~H"""
    <div
      class={
        classes([
          "rounded-lg border px-4 py-3 text-sm bg-background text-foreground",
          @class,
          @kind == "error" && "border-destructive/50 text-destructive dark:border-destructive"
        ])
      }
      {@rest}
    >
      <div class="flex w-full gap-2">
        <.icon :if={not is_nil(@icon)} name={@icon} />
        <div>
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    </div>
    """
  end
end
