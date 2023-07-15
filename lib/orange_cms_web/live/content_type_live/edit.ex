defmodule OrangeCmsWeb.ContentTypeLive.Edit do
  @moduledoc false
  use OrangeCmsWeb, :live_view

  alias OrangeCms.Content

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    content_type = Content.get_content_type!(id)

    changeset = Content.change_content_type(content_type)

    {:noreply,
     socket
     |> assign(:page_title, "Edit content type")
     |> assign(:content_type, content_type)
     |> assign(
       :form,
       changeset
     )}
  end

  @impl true
  def handle_event("add_field", _params, socket) do
    socket =
      update(socket, :form, fn changeset ->
        existing = Ecto.Changeset.get_field(changeset, :frontmatter_schema, [])
        Ecto.Changeset.put_embed(changeset, :frontmatter_schema, existing ++ [%{name: "new field"}])
      end)

    {:noreply, socket}
  end

  @impl true
  def handle_event("remove_field", %{"index" => index}, socket) do
    index = String.to_integer(index)
    # TODO: fix bugs "remove all field cannot save"
    fields =
      socket.assigns.form
      |> Ecto.Changeset.get_field(:frontmatter_schema, [])
      |> List.delete_at(index)

    changeset = Ecto.Changeset.put_embed(socket.assigns.form, :frontmatter_schema, fields)

    {:noreply, assign(socket, :form, changeset)}
  end

  @impl true
  def handle_event("validate", %{"content_type" => params}, socket) do
    form = Content.change_content_type(socket.assigns.content_type, params)

    {:noreply, assign(socket, :form, form)}
  end

  @impl true
  def handle_event("save_field_order", %{"ids" => keys}, socket) do
    fields = Ecto.Changeset.get_field(socket.assigns.form, :frontmatter_schema, [])

    # pick the fields in the order of the keys
    fields =
      Enum.map(keys, fn key ->
        Enum.find(fields, fn field -> field.key == key end)
      end)

    changeset = Ecto.Changeset.put_embed(socket.assigns.form, :frontmatter_schema, fields)

    case OrangeCms.Repo.update(changeset) do
      {:ok, entry} ->
        changeset = Content.change_content_type(entry, %{})

        {:noreply,
         socket
         |> put_flash(:info, "Content type updated successfully")
         |> assign(form: changeset, content_type: entry)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, changeset)}
    end
  end

  @impl true
  def handle_event("save", %{"content_type" => params}, socket) do
    case Content.update_content_type(socket.assigns.content_type, params) do
      {:ok, entry} ->
        changeset = Content.change_content_type(entry, params)

        {:noreply,
         socket
         |> put_flash(:info, "Content type updated successfully")
         |> assign(form: changeset, content_type: entry)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, changeset)}
    end
  end
end
