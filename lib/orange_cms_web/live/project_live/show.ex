defmodule OrangeCmsWeb.ProjectLive.Show do
  use OrangeCmsWeb, :live_view

  alias OrangeCms.Projects
  alias OrangeCms.Projects.Project

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, project: nil)}
  end

  @impl true
  def handle_params(%{"project_id" => id}, _url, socket) do
    project = Project.get!(id)
    {:noreply, assign(socket, project: project)}
  end
end
