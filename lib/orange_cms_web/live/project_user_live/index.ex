defmodule OrangeCmsWeb.ProjectUserLive.Index do
  use OrangeCmsWeb, :live_view

  alias OrangeCms.Projects
  alias OrangeCms.Projects.ProjectUser
  alias OrangeCms.Repo

  @impl true
  def mount(_params, _session, socket) do
    project =
      socket.assigns.current_project
      |> Repo.preload(project_users: :user)

    {:ok, stream(socket, :project_users, project.project_users)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Member")
    |> assign(:project_user, Projects.get_project_user!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Add Member")
    |> assign(:project_user, %ProjectUser{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Members")
    |> assign(:project_user, nil)
  end

  @impl true
  def handle_info({OrangeCmsWeb.ProjectUserLive.FormComponent, {:saved, user}}, socket) do
    user = Repo.preload(user, :user)
    {:noreply, stream_insert(socket, :project_users, user)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    user = Projects.get_project_user!(id)
    Projects.delete_project_user(user)

    {:noreply, stream_delete(socket, :project_users, user)}
  end
end
