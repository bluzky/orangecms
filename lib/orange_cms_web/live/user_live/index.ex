defmodule OrangeCmsWeb.UserLive.Index do
  @moduledoc false
  use OrangeCmsWeb, :live_view

  alias OrangeCms.Accounts.OUser

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :users, OUser.read!())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit User")
    |> assign(:user, OUser.get!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New User")
    |> assign(:user, %OUser{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Users")
    |> assign(:user, nil)
  end

  @impl true
  def handle_info({OrangeCmsWeb.UserLive.FormComponent, {:saved, user}}, socket) do
    {:noreply, stream_insert(socket, :users, user)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    user = OUser.get!(id)
    {:ok, _} = OUser.delete(user)

    {:noreply, stream_delete(socket, :users, user)}
  end
end
