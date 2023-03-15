defmodule OrangeCmsWeb.ProjectLive.Index do
  use OrangeCmsWeb, :live_view

  alias OrangeCms.Projects
  alias OrangeCms.Projects.Project

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :projects, Project.read_all!())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Project")
    |> assign(:project, %Project{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Projects")
    |> assign(:project, nil)
  end

  @impl true
  def handle_info({OrangeCmsWeb.ProjectLive.FormComponent, {:saved, project}}, socket) do
    {:noreply, stream_insert(socket, :projects, project)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    project = Project.get!(id)
    :ok = Project.delete(project)

    {:noreply, stream_delete(socket, :projects, project)}
  end
end
