defmodule OrangeCmsWeb.MenuAssign do
  @moduledoc """
  Ensures common `assigns` are applied to all LiveViews attaching this hook.
  """
  alias OrangeCms.Content

  def on_mount(_, params, _session, socket) do
    type =
      if socket.view in [OrangeCmsWeb.ContentEntryLive.Index, OrangeCmsWeb.ContentEntryLive.Edit] do
        params["type"]
      end

    content_types = Content.list_content_types(socket.assigns.current_project.id)

    current_type = Enum.find(content_types, &(&1.key == type))

    {:cont,
     Phoenix.Component.assign(socket,
       content_types: content_types,
       current_type: current_type
     )}
  end
end
