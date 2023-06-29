defmodule OrangeCmsWeb.UserLive.Show do
  @moduledoc false
  use OrangeCmsWeb, :live_view

  alias OrangeCms.Accounts.OUser

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:user, OUser.get!(id))}
  end

  defp page_title(:show), do: "Show User"
  defp page_title(:edit), do: "Edit User"
end
