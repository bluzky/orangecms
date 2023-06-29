defmodule OrangeCmsWeb.ContentTypeLive.Show do
  @moduledoc false
  use OrangeCmsWeb, :live_view

  alias OrangeCms.Content

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:content_type, Content.get_content_type!(id))}
  end

  defp page_title(:show), do: "Show Content type"
  defp page_title(:edit), do: "Edit Content type"
end
