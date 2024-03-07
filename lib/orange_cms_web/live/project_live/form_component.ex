defmodule OrangeCmsWeb.ProjectLive.FormComponent do
  @moduledoc false
  use OrangeCmsWeb, :live_component

  alias OrangeCms.Projects
  alias OrangeCms.Projects.Project

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form
        class="space-y-6"
        for={@form}
        id="project-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.form_item field={@form[:name]} label="What is your project's name?">
          <Input.input field={@form[:name]} type="text" phx-debounce="500" />
        </.form_item>
        <div class="flex w-full flex-row-reverse">
          <.button icon="inbox_arrow_down" phx-disable-with="Saving...">
            Save project
          </.button>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def update(%{project: project} = assigns, socket) do
    changeset = Project.changeset(project, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"project" => project_params}, socket) do
    changeset =
      socket.assigns.project
      |> Project.changeset(project_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"project" => project_params}, socket) do
    save_project(socket, socket.assigns.action, project_params)
  end

  defp save_project(socket, :new, project_params) do
    with {:ok, parsed_params} <- Skema.cast(project_params, Projects.CreateProjectParams),
         {:ok, project} <- Projects.create_project(parsed_params, context(socket)) do
      notify_parent({:saved, project})

      {:noreply,
       socket
       |> put_flash(:info, "Project created successfully")
       |> push_navigate(to: ~p"/p/#{project.code}")}
    else
      {:error, error} ->
        {:noreply, assign_form(socket, error)}
    end
  end

  defp assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset, as: "project"))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
