defmodule OrangeCmsWeb.ContentTypeLive.Index do
  use OrangeCmsWeb, :live_view

  alias OrangeCms.Content
  alias OrangeCms.Content.ContentType

  @impl true
  def mount(_params, _session, socket) do
    ContentType
    |> Ash.Query.for_read(:read, %{})
    |> Content.read()
    |> case do
      {:ok, entries} ->
        {:ok, stream(socket, :content_types, entries)}

      {:error, _err} ->
        {:ok, stream(socket, :content_types, [])}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Content type")
    |> assign(:content_type, %ContentType{})
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
    {:ok, _} = Content.delete_content_type(content_type)

    {:noreply, stream_delete(socket, :content_types, content_type)}
  end
end
