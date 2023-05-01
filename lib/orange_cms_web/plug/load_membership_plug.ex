defmodule OrangeCmsWeb.LoadMembershipPlug do
  @moduledoc """
  Load user membership for current project and set as actor
  """

  def init(options), do: options

  def call(%{assigns: assigns, params: %{"project_id" => project_id}} = conn, _opts) do
    Ash.set_actor(assigns.current_user)

    membership =
      OrangeCms.Projects.ProjectUser.get_membership!(
        project_id,
        assigns.current_user.id
      )

    Ash.set_actor(membership)
    conn
  end
end
