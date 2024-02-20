defmodule OrangeCmsWeb.LoadProject do
  @moduledoc """
  Ensures common `assigns` are applied to all LiveViews attaching this hook.
  """
  use OrangeCmsWeb, :verified_routes

  import Phoenix.LiveView, only: [push_navigate: 2, put_flash: 3]

  def on_mount(_, params, _session, socket) do
    project_id = params["project_id"]

    projects = OrangeCms.Projects.list_user_projects(OrangeCms.get_actor())

    case Enum.find(projects, &(&1.id == project_id)) do
      %{} = project ->
        socket =
          Phoenix.Component.assign(socket,
            current_project: project,
            projects: projects
          )

        cond do
          !project.setup_completed and
              not (socket.view == OrangeCmsWeb.ProjectLive.Show and
                       socket.assigns.live_action in [:github_setup]) ->
            {:halt, push_navigate(socket, to: ~p"/p/#{project.id}/setup/github")}

          project.setup_completed and socket.view == OrangeCmsWeb.ProjectLive.Show and
              socket.assigns.live_action in [:github_setup] ->
            {:halt, push_navigate(socket, to: ~p"/p/#{project.id}")}

          true ->
            {:cont, socket}
        end

      nil ->
        {:halt,
         socket
         |> put_flash(:error, "No project selected!")
         |> push_navigate(to: ~p"/p")}
    end
  end
end
