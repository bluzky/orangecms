defmodule OrangeCmsWeb.Components.LadUI do
  @moduledoc false
  def component do
    quote do
      use Phoenix.Component

      import OrangeCmsWeb.Components.LadUI.Helpers
      import Tails, only: [classes: 1]

      alias OrangeCmsWeb.Components.LadUI.LadJS
      alias Phoenix.LiveView.JS
    end
  end

  @doc """
  When used, dispatch to the appropriate macro.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  defmacro __using__(_) do
    quote do
      import OrangeCmsWeb.Components.LadUI.Alert
      import OrangeCmsWeb.Components.LadUI.AlertDialog
      import OrangeCmsWeb.Components.LadUI.Button
      import OrangeCmsWeb.Components.LadUI.Card
      import OrangeCmsWeb.Components.LadUI.Collapsible
      import OrangeCmsWeb.Components.LadUI.Dialog
      import OrangeCmsWeb.Components.LadUI.Display
      import OrangeCmsWeb.Components.LadUI.DropdownMenu
      import OrangeCmsWeb.Components.LadUI.Form
      import OrangeCmsWeb.Components.LadUI.Icon
      import OrangeCmsWeb.Components.LadUI.Input, except: [input: 1]
      import OrangeCmsWeb.Components.LadUI.ScrollArea
      import OrangeCmsWeb.Components.LadUI.Select
      import OrangeCmsWeb.Components.LadUI.Sheet
      import OrangeCmsWeb.Components.LadUI.Table
      import OrangeCmsWeb.Components.LadUI.Tabs
      import OrangeCmsWeb.Components.LadUI.Tooltip

      alias OrangeCmsWeb.Components.LadUI.Input
    end
  end
end
