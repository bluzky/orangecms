defmodule OrangeCmsWeb.LoadMembership do
  @moduledoc """
  Load user membership for current project and set as actor
  """
  use OrangeCmsWeb, :verified_routes

  def on_mount(_, params, _session, %{assigns: assigns} = socket) do
    membership =
      OrangeCms.Projects.ProjectUser.get_membership!(
        assigns.current_project.id,
        assigns.current_user.id
      )

    Ash.set_actor(membership)
    {:cont, socket}
  end
end
