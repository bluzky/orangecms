defmodule OrangeCmsWeb.ContentTypeLive.Edit do
  use OrangeCmsWeb, :live_view

  alias OrangeCms.Content
  alias OrangeCms.Content.ContentType

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    content_type =
      ContentType
      |> Ash.Query.for_read(:by_id, %{id: id})
      |> Content.read_one!()

    {:noreply,
     socket
     |> assign(:page_title, "Edit content type")
     |> assign(:content_type, content_type)}
  end
end
