defmodule OrangeCmsWeb.ContentTypeLive.FormComponent do
  @moduledoc false
  use OrangeCmsWeb, :live_component

  alias OrangeCms.Content

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form
        for={@form}
        id="content_type-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        class="space-y-6"
      >
        <.form_item field={@form[:name]} label="Name">
          <Input.input field={@form[:name]} placeholder="eg: Post" />
        </.form_item>
        <.form_item
          field={@form[:key]}
          label="Key"
          description="A key used to query content collection via API. It must be unique within project"
        >
          <Input.input field={@form[:key]} placeholder="eg: blog-post" />
        </.form_item>

        <div class="w-full flex flex-row-reverse">
          <.button icon_right="arrow-right" phx-disable-with="Checking...">
            Next
          </.button>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def update(%{content_type: content_type} = assigns, socket) do
    changeset = Content.change_content_type(content_type)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"content_type" => params}, socket) do
    changeset =
      socket.assigns.content_type
      |> Content.change_content_type(params)
      |> Map.put(:action, :validate)
      |> IO.inspect()

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"content_type" => params}, socket) do
    save(socket, socket.assigns.action, params)
  end

  defp save(socket, :new, params) do
    params = Map.put(params, "project_id", socket.assigns.current_project.id)

    case Content.create_content_type(params) do
      {:ok, entry} ->
        notify_parent({:saved, entry})

        {:noreply,
         socket
         |> put_flash(:info, "Content type created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
