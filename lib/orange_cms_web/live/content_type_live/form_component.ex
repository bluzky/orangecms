defmodule OrangeCmsWeb.ContentTypeLive.FormComponent do
  use OrangeCmsWeb, :live_component

  alias OrangeCms.Content
  alias OrangeCms.Content.ContentType

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage content_type records in your database.</:subtitle>
      </.header>

      <.simple_form
        :let={f}
        for={@form}
        id="content_type-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={f[:name]} type="text" label="Name" />
        <.input field={f[:key]} type="text" label="Key" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Content type</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{content_type: content_type} = assigns, socket) do
    form =
      if content_type.id do
        AshPhoenix.Form.for_update(content_type, :update, api: Content)
      else
        AshPhoenix.Form.for_create(ContentType, :create, api: Content)
      end

    {:ok,
     socket
     |> assign(assigns)
     |> assign(form: form)}
  end

  @impl true
  def handle_event("validate", %{"form" => content_type_params}, socket) do
    form =
      AshPhoenix.Form.validate(
        socket.assigns.form,
        content_type_params
      )

    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("save", %{"form" => content_type_params}, socket) do
    form =
      AshPhoenix.Form.validate(
        socket.assigns.form,
        content_type_params
      )

    case AshPhoenix.Form.submit(form) do
      {:ok, entry} ->
        {:noreply,
         socket
         |> put_flash(:success, "Content type updated successfully")
         |> push_navigate(to: scoped_path(socket, "/content_types/#{entry.id}"))}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end
end
