defmodule OrangeCmsWeb.Components.Display do
  @moduledoc """
  Some display utility component includes:

  - separator
  """
  use Phoenix.Component

  attr :class, :string, default: nil
  attr :orientation, :string, values: ["horizontal", "vertical"], default: "horizontal"
  attr :rest, :global

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
end
