defmodule OrangeCmsWeb.ContentEntryLive.Index do
  @moduledoc false
  use OrangeCmsWeb, :live_view

  alias OrangeCms.Content
  alias OrangeCms.Content.ContentEntry
  alias OrangeCms.Content.ContentType

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       type: nil,
       content_entries: []
     )}
  end

  @impl true
  def handle_params(%{"type" => type}, _uri, socket) do
    content_type = Content.find_content_type(socket.assigns.current_project.id, key: type)

    content_entries =
      Content.list_content_entries(socket.assigns.current_project.id,
        content_type_id: content_type.id
      )

    {:noreply,
     socket
     |> assign(:content_type, content_type)
     |> stream(:content_entries, content_entries)}
  end

  def handle_event("create_entry", _params, socket) do
    content_type = socket.assigns.content_type

    %{
      title: "My awesome title",
      raw_body: "",
      content_type_id: content_type.id,
      project_id: socket.assigns.current_project.id,
      integration_info: %{}
    }
    |> Content.create_content_entry()
    |> case do
      {:ok, entry} ->
        {:noreply,
         socket
         |> push_navigate(to: scoped_path(socket, "/content/#{content_type.key}/#{entry.id}"))
         |> put_flash(:info, "Create entry successfully!")}

      {:error, _error} ->
        {:noreply, put_flash(socket, :error, "Cannot create new #{content_type.name}")}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    entry = Content.get_content_entry!(id)
    Content.delete_content_entry(entry)
    socket = stream_delete(socket, :content_entries, entry)

    {:noreply, socket}
  end
end
