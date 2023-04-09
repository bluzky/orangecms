defmodule OrangeCmsWeb.ProjectUserLive.FormComponent do
  use OrangeCmsWeb, :live_component

  alias OrangeCms.Projects
  alias OrangeCms.Projects.ProjectUser

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.simple_form
        :let={f}
        for={@form}
        id="user-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={f[:user_id]} type="text" label="User" />
        <:actions>
          <.button class="btn-md btn-secondary" phx-disable-with="Saving...">
            <.icon name="inbox" /> Save Member
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{project_user: project_user} = assigns, socket) do
    form =
      if project_user.id do
        AshPhoenix.Form.for_update(project_user, :update, api: Projects)
      else
        AshPhoenix.Form.for_create(ProjectUser, :create, api: Projects)
      end

    {:ok,
     socket
     |> assign(assigns)
     |> assign(form: form)}
  end

  @impl true
  def handle_event("validate", %{"form" => user_params}, socket) do
    form =
      AshPhoenix.Form.validate(
        socket.assigns.form,
        user_params
      )

    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("save", %{"form" => user_params}, socket) do
    user_params = Map.put(user_params, "project_id", socket.assigns.current_project.id)

    form =
      AshPhoenix.Form.validate(
        socket.assigns.form,
        user_params
      )

    case AshPhoenix.Form.submit(form) do
      {:ok, entry} ->
        {:noreply,
         socket
         |> put_flash(:success, "User updated successfully")
         |> push_navigate(to: scoped_path(socket, "/members"))}

      {:error, form} ->
        {:noreply,
         socket
         |> assign(form: form)}
    end
  end
end
