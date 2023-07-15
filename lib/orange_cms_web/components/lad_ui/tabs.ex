defmodule OrangeCmsWeb.Components.LadUI.Tabs do
  @moduledoc """
  Implement of card components from https://ui.shadcn.com/docs/components/card


  ## Example:


      <.tabs default="account" id="settings" class="w-[400px]">
      <.tabs_list class="grid w-full grid-cols-2">
        <.tabs_trigger root="settings" value="account">account</.tabs_trigger>
        <.tabs_trigger root="settings" value="password">password</.tabs_trigger>
      </.tabs_list>
      <.tabs_content value="account">
          <.card>
          <.card_content class="p-6">
            Account
          </.card_content>
        </.card>
      </.tabs_content>
      <.tabs_content value="password">
        <.card>
          <.card_content class="p-6">
            Password
          </.card_content>
        </.card>
      </.tabs_content>
      </.tabs>
  """
  use OrangeCmsWeb.Components.LadUI, :component

  attr(:id, :string, required: true, doc: "id for root tabs tag")
  attr(:default, :string, required: true, doc: "default active tab")
  attr(:class, :string, default: nil)
  slot(:inner_block, required: true)
  attr(:rest, :global)

  def tabs(assigns) do
    ~H"""
    <div class={[@class]} id={@id} {@rest} phx-mounted={show_tab(@id, @default)}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr(:class, :string, default: nil)
  slot(:inner_block, required: true)
  attr(:rest, :global)

  def tabs_list(assigns) do
    ~H"""
    <div
      class={[
        "inline-flex h-10 items-center justify-center rounded-md bg-muted p-1 text-muted-foreground",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :root, :string, required: true, doc: "id of root tabs tag"
  attr(:value, :string, required: true, doc: "this value is used to show the tab content with same value")
  attr(:class, :string, default: nil)
  attr :disabled, :boolean, default: false
  slot(:inner_block, required: true)
  attr(:rest, :global)

  def tabs_trigger(assigns) do
    ~H"""
    <button
      class={[
        "tabs-trigger inline-flex items-center justify-center whitespace-nowrap rounded-sm px-3 py-1.5 text-sm font-medium ring-offset-background transition-all focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 data-[state=active]:bg-background data-[state=active]:text-foreground data-[state=active]:shadow-sm",
        @class
      ]}
      disabled={@disabled}
      data-value={@value}
      phx-click={show_tab(@root, @value)}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  attr :value, :string, required: true, doc: "unique value for tab content, this must match tab trigger value"
  attr(:class, :string, default: nil)
  slot(:inner_block, required: true)
  attr(:rest, :global)

  def tabs_content(assigns) do
    ~H"""
    <div
      class={[
        "tabs-content hidden mt-2 ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
        @class
      ]}
      data-value={@value}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # Set selected tab to active
  # show appropriate tab content
  defp show_tab(root, value) do
    %JS{}
    |> JS.set_attribute({"data-state", ""}, to: "##{root} .tabs-trigger[data-state=active]")
    |> JS.set_attribute({"data-state", "active"}, to: "##{root} .tabs-trigger[data-value=#{value}]")
    |> JS.hide(to: "##{root} .tabs-content")
    |> JS.show(to: "##{root} .tabs-content[data-value=#{value}]")
  end
end
