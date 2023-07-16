defmodule OrangeCmsWeb.ContentEntryLive.Index do
  @moduledoc false
  use OrangeCmsWeb, :live_view

  alias OrangeCms.Content
  alias OrangeCms.Content.ContentType
  alias OrangeCms.ContentEntryLive.ContentTypeList

  @impl true
  def mount(params, _session, socket) do
    content_types = Content.list_content_types(socket.assigns.current_project.id)

    if params["type"] do
      content_type = Enum.find(content_types, &(&1.key == params["type"]))

      # load content entries
      content_entries =
        Content.list_content_entries(socket.assigns.current_project.id,
          content_type_id: content_type.id
        )

      {:ok,
       socket
       |> assign(
         content_types: content_types,
         content_type: content_type
       )
       |> stream(:content_entries, content_entries)}
    else
      {:ok, push_navigate(socket, to: scoped_path(socket, "/content/#{hd(content_types).key}"))}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new_content_type, _params) do
    socket
    |> assign(:page_title, "New Collection")
    |> assign(:content_type, %ContentType{project_id: socket.assigns.current_project.id})
  end

  defp apply_action(socket, :index, _params) do
    assign(socket, :page_title, socket.assigns.content_type.name)
  end

  def handle_event("create_entry", _params, socket) do
    content_type = socket.assigns.content_type

    %{
      title: "My awesome title",
      body: "",
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
