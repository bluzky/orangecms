defmodule OrangeCmsWeb.ProjectMemberLive.Index do
  @moduledoc false
  use OrangeCmsWeb, :live_view

  alias OrangeCms.Projects
  alias OrangeCms.Projects.ProjectMember
  alias OrangeCms.Repo

  @impl true
  def mount(_params, _session, socket) do
    project = Repo.preload(socket.assigns.current_project, project_members: :user)

    {:ok, stream(socket, :project_members, project.project_members)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Member")
    |> assign(:project_member, Projects.get_project_member!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Add Member")
    |> assign(:project_member, %ProjectMember{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Members")
    |> assign(:project_member, nil)
  end

  @impl true
  def handle_info({OrangeCmsWeb.ProjectMemberLive.FormComponent, {:saved, user}}, socket) do
    user = Repo.preload(user, :user)
    {:noreply, stream_insert(socket, :project_members, user)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    user = Projects.get_project_member!(id)
    Projects.delete_project_member(user)

    {:noreply, stream_delete(socket, :project_members, user)}
  end
end
