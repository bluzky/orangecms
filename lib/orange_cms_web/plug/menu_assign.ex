defmodule OrangeCmsWeb.MenuAssign do
  @moduledoc """
  Ensures common `assigns` are applied to all LiveViews attaching this hook.
  """
  use OrangeCmsWeb, :live_view

  alias OrangeCmsWeb.Router.Helpers, as: Routes

  def on_mount(_, params, _session, socket) do
    project_id = params["project_id"]

    menu = [
      {"Collections", Routes.content_entry_index_path(socket, :index, project_id)},
      {"Content types", Routes.content_type_index_path(socket, :index, project_id)},
      {"Team", Routes.project_member_index_path(socket, :index, project_id)}
    ]

    socket =
      attach_hook(socket, :set_left_menu_active_path, :handle_params, fn
        _params, url, socket ->
          uri = URI.parse(url)
          {:cont, assign(socket, current_uri: uri, current_path: uri.path)}
      end)

    {:cont,
     Phoenix.Component.assign(socket,
       menu: menu
     )}
  end
end
