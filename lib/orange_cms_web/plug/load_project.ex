defmodule OrangeCmsWeb.LoadProject do
  @moduledoc """
  Ensures common `assigns` are applied to all LiveViews attaching this hook.
  """
  use OrangeCmsWeb, :live_view
  alias OrangeCms.Projects.Project

  def on_mount(_, params, _session, socket) do
    project_id = params["project_id"]
    projects = Project.read_all!()

    case Enum.find(projects, &(&1.id == project_id)) do
      %{} = project ->
        Ash.set_tenant(project.id)

        {:cont,
         Phoenix.Component.assign(socket,
           current_project: project,
           projects: projects
         )}

      nil ->
        {:halt,
         socket
         |> put_flash(:error, "No project selected!")
         |> push_navigate(to: ~p"/app/projects")}
    end
  end
end
