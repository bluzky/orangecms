defmodule OrangeCmsWeb.ProjectLive.Show do
  @moduledoc false
  use OrangeCmsWeb, :live_view

  alias OrangeCms.Projects

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       project: nil,
       page_title: ""
     )}
  end

  @impl true
  def handle_params(%{"project_id" => id}, _url, socket) do
    project = Projects.get_project!(id)
    {:noreply, assign(socket, project: project, page_title: project.name)}
  end

  def apply_action(socket, :github_setup, params) do
    socket
    |> assign(:page_title, "Setup github")
    |> assign(:form, to_form(params))
  end

  def apply_action(socket, :github_import_content, _params) do
    assign(socket, :page_title, "Import content")
  end

  @impl true
  def handle_info({OrangeCmsWeb.ProjectLive.SetupGithubForm, {:saved, project}}, socket) do
    {:noreply, assign(socket, :project, project)}
  end
end
