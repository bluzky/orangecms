defmodule OrangeCmsWeb.MenuAssign do
  @moduledoc """
  Ensures common `assigns` are applied to all LiveViews attaching this hook.
  """
  import Phoenix.LiveView
  alias OrangeCms.Content
  alias OrangeCms.Content.ContentType

  def on_mount(_, params, _session, socket) do
    type =
      if socket.view in [OrangeCmsWeb.ContentEntryLive.Index, OrangeCmsWeb.ContentEntryLive.Edit] do
        params["type"]
      end

    case ContentType.read_all() do
      {:ok, content_types} ->
        current_type = Enum.find(content_types, &(&1.key == type))

        {:cont,
         Phoenix.Component.assign(socket,
           content_types: content_types,
           current_type: current_type
         )}

      {:error, err} ->
        {:halt, socket}
    end
  end
end
