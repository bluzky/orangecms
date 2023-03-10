defmodule OrangeCmsWeb.ContentEntryLive.Index do
  use OrangeCmsWeb, :live_view

  alias OrangeCms.Content
  alias OrangeCms.Content.ContentType
  alias OrangeCms.Content.ContentEntry

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       type: nil,
       content_entries: []
     )}
  end

  def handle_params(%{"type" => type}, _uri, socket) do
    content_type = ContentType.get_by_key!(type)

    content_entries = ContentEntry.get_by_type!(content_type.id)

    {:noreply,
     socket
     |> assign(content_type: content_type)
     |> stream(:content_entries, content_entries)}
  end

  def handle_event("create_entry", _params, socket) do
    content_type = socket.assigns.content_type

    ContentEntry
    |> Ash.Changeset.for_create(:create, %{
      title: "My awesome title",
      raw_body: "",
      content_type_id: content_type.id
    })
    |> Content.create()
    |> case do
      {:ok, entry} ->
        {:noreply,
         socket
         |> push_navigate(to: ~p"/app/content/#{content_type.key}/#{entry.id}")
         |> put_flash(:info, "Create entry successfully!")}

      {:error, error} ->
        {:noreply, put_flash(socket, :error, "Cannot create new #{content_type.name}")}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    entry = ContentEntry.get!(id)
    :ok = ContentEntry.delete(entry)

    socket = stream_delete(socket, :content_entries, entry)

    {:noreply, socket}
  end
end
