defmodule OrangeCmsWeb.ProjectLive.FormComponent do
  use OrangeCmsWeb, :live_component

  alias OrangeCms.Projects
  alias OrangeCms.Projects.Project

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage project records in your database.</:subtitle>
      </.header>

      <.simple_form
        :let={f}
        for={@form}
        id="project-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={f[:name]} type="text" label="Name" />
        <.input
          field={f[:type]}
          type="select"
          label="Type"
          options={OrangeCms.Projects.ProjectType.values()}
        />
        <:actions>
          <.button
            class="btn btn-secondary btn-md"
            icon="inbox_arrow_down"
            phx-disable-with="Saving..."
          >
            Save project
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    form = AshPhoenix.Form.for_create(Project, :create, api: Projects)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(form: form)}
  end

  @impl true
  def handle_event("validate", %{"form" => project_params}, socket) do
    form =
      AshPhoenix.Form.validate(
        socket.assigns.form,
        project_params
      )

    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("save", %{"form" => project_params}, socket) do
    form =
      AshPhoenix.Form.validate(
        socket.assigns.form,
        project_params
      )

    case AshPhoenix.Form.submit(form) do
      {:ok, entry} ->
        {:noreply,
         socket
         |> put_flash(:info, "Created project successfully")
         |> push_navigate(to: ~p"/app/p/#{entry.id}")}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end
end
