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
    content_type = ContentType.get!(id)

    {:noreply,
     socket
     |> assign(:page_title, "Edit content type")
     |> assign(:content_type, content_type)
     |> assign(:tab, "general")}
  end

  def handle_event("switch_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, :tab, tab)}
  end

  def switch_tab(js \\ %JS{}, tab) do
    js
    |> JS.add_class("hidden", to: "#general, #image-settings, #frontmatter")
    |> JS.remove_class("hidden", to: tab)
    |> JS.remove_class("text-cyan-500 border-current", to: "#tab-header a")
    |> JS.add_class("border-transparent", to: "#tab-header a")
    |> JS.add_class("text-cyan-500 border-current", to: "#{tab}-hd")
    |> JS.remove_class("border-transparent", to: "#{tab}-hd")
  end
end
