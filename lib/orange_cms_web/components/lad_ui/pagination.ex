defmodule OrangeCmsWeb.Components.LadUI.Pagination do
  @moduledoc false
  use OrangeCmsWeb.Components.LadUI, :component

  import OrangeCmsWeb.Components.LadUI.Button
  import OrangeCmsWeb.Components.LadUI.Icon
  import OrangeCmsWeb.Components.LadUI.Select

  attr :page_number, :integer, required: true
  attr :page_size, :integer, required: true
  attr :total_pages, :integer, required: true
  attr :total_entries, :integer, required: true
  attr :on_click_fn, :any, required: true
  attr :page_size_options, :list, default: []
  attr :class, :string, default: nil

  def pagination(assigns) do
    ~H"""
    <div class={classes(["flex items-center justify-between px-2", @class])}>
      <div class="text-muted-foreground flex-1 text-sm">
        Row <%= (@page_number - 1) * @page_size + 1 %> - <%= min(
          @page_number * @page_size,
          @total_entries
        ) %> of <%= @total_entries %>.
      </div>
      <div class="flex items-center space-x-6 lg:space-x-8">
        <div class="flex items-center space-x-2">
          <p class="text-sm font-medium">Rows per page</p>
          <.select value={@page_size} id="pagination-select">
            <.select_trigger class="w-[70px] h-8">
              <.select_value placeholder={@page_size} />
            </.select_trigger>
            <.select_content side="top">
              <.select_item
                :for={page_size <- [10, 20, 30, 40, 50]}
                value={page_size}
                phx-click={@on_click_fn.(1, page_size)}
              >
                <%= page_size %>
              </.select_item>
            </.select_content>
          </.select>
        </div>
        <div class="w-[100px] flex items-center justify-center text-sm font-medium">
          Page <%= @page_number %> of <%= @total_pages %>
        </div>
        <div class="flex items-center space-x-2">
          <.button
            variant="outline"
            class="hidden h-8 w-8 p-0 lg:flex"
            disabled={@page_number == 1}
            phx-click={@on_click_fn.(1, @page_size)}
          >
            <span class="sr-only">Go to first page</span>
            <.icon name="chevron-double-left" class="h-4 w-4" />
          </.button>
          <.button
            variant="outline"
            class="h-8 w-8 p-0"
            disabled={@page_number == 1}
            phx-click={@on_click_fn.(@page_number - 1, @page_size)}
          >
            <span class="sr-only">Go to previous page</span>
            <.icon name="chevron-left" class="h-4 w-4" />
          </.button>
          <.button
            variant="outline"
            class="h-8 w-8 p-0"
            disabled={@page_number == @total_pages}
            phx-click={@on_click_fn.(@page_number + 1, @page_size)}
          >
            <span class="sr-only">Go to next page</span>
            <.icon name="chevron-right" class="h-4 w-4" />
          </.button>
          <.button
            variant="outline"
            class="hidden h-8 w-8 p-0 lg:flex"
            disabled={@page_number == @total_pages}
            phx-click={@on_click_fn.(@total_pages, @page_size)}
          >
            <span class="sr-only">Go to last page</span>
            <.icon name="chevron-double-right" class="h-4 w-4" />
          </.button>
        </div>
      </div>
    </div>
    """
  end
end
