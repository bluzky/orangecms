defmodule OrangeCmsWeb.ContentTypeLive.Index do
  @moduledoc false
  use OrangeCmsWeb, :live_view

  alias OrangeCms.Content
  alias OrangeCms.Content.ContentType

  @impl true
  def mount(_params, _session, socket) do
    entries = Content.list_content_types(%{}, context(socket))
    {:ok, stream(socket, :content_types, entries)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Content type")
    |> assign(:content_type, %ContentType{project_id: socket.assigns.current_project.id})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Content types")
    |> assign(:content_type, nil)
  end

  @impl true
  def handle_info({OrangeCmsWeb.ContentTypeLive.FormComponent, {:saved, content_type}}, socket) do
    {:noreply, stream_insert(socket, :content_types, content_type)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    content_type = Content.get_content_type!(id)
    Content.delete_content_type(content_type)

    socket = stream_delete(socket, :content_types, content_type)

    {:noreply, socket}
  end
end
