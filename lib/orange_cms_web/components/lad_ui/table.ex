defmodule OrangeCmsWeb.Components.LadUI.Table do
  @moduledoc """
  Implement of table components from https://ui.shadcn.com/docs/components/table
  """
  use OrangeCmsWeb.Components.LadUI, :component

  @doc """
  Card component

  ## Examples:

    <.stable>
       <.table_caption>A list of your recent invoices.</.table_caption>
       <.table_header>
         <.table_row>
           <.table_head class="w-[100px]">id</.table_head>
           <.table_head>Title</.table_head>
           <.table_head>Status</.table_head>
           <.table_head class="text-right">action</.table_head>
         </.table_row>
       </.table_header>
       <.table_body>
         <.table_row :for={{id, entry} <- @streams.content_entries} id={id}>
           <.table_cell class="font-medium"><%= id %></.table_cell>
           <.table_cell><%= entry.title %></.table_cell>
           <.table_cell><%= entry.project_id %></.table_cell>
           <.table_cell class="text-right">
             <.link
               navigate={scoped_path(assigns, "/content/\#{@content_type.key}/\#{entry.id}")}
               class="btn-action"
             >
               <Heroicons.pencil_square class="w-4 h-4" /> Edit
             </.link>

             <.link
               phx-click={JS.push("delete", value: %{id: entry.id})}
               data-confirm="Are you sure?"
               class="btn-action"
             >
               <Heroicons.x_mark class="w-4 h-4 text-error" /> Delete
             </.link>
           </.table_cell>
         </.table_row>
       </.table_body>
      </.stable>
  """
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def stable(assigns) do
    ~H"""
    <table class={classes(["w-full text-sm", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </table>
    """
  end

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def table_header(assigns) do
    ~H"""
    <thead class={classes(["[&_tr]:border-b", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </thead>
    """
  end

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def table_caption(assigns) do
    ~H"""
    <caption class={classes(["mt-4 text-sm text-muted-foreground caption-bottom", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </caption>
    """
  end

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def table_row(assigns) do
    ~H"""
    <tr
      class={
        classes([
          "border-b transition-colors hover:bg-muted/50 data-[state=selected]:bg-muted",
          @class
        ])
      }
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </tr>
    """
  end

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def table_head(assigns) do
    ~H"""
    <th
      class={
        classes([
          "h-10 px-2 text-left align-middle font-medium text-muted-foreground [&:has([role=checkbox])]:pr-0 [&>[role=checkbox]]:translate-y-[2px]",
          @class
        ])
      }
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </th>
    """
  end

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def table_body(assigns) do
    ~H"""
    <tbody class={classes(["[&_tr:last-child]:border-0", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </tbody>
    """
  end

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def table_cell(assigns) do
    ~H"""
    <td class={classes(["p-4 align-middle [&:has([role=checkbox])]:pr-0", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </td>
    """
  end
end
