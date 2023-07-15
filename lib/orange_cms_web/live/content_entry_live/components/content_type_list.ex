defmodule OrangeCms.ContentEntryLive.ContentTypeList do
  @moduledoc false
  use OrangeCmsWeb, :html

  attr :content_types, :list, required: true
  attr :current_type, :map, required: true
  attr :route_fn, :any, required: true

  def component(assigns) do
    ~H"""
    <.scroll_area class="w-full">
      <div class="space-y-2 py-4">
        <%= for item <- @content_types do %>
          <div class={["text-sm hover:bg-muted rounded-lg", @current_type.id == item.id && "bg-muted"]}>
            <.link
              navigate={@route_fn.("/content/#{item.key}")}
              class="flex items-center gap-2 px-3 py-2"
            >
              <.icon name="folder" class="h-5 w-5" /> <label><%= item.name %></label>
            </.link>
          </div>
        <% end %>
      </div>
    </.scroll_area>
    """
  end
end
