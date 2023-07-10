defmodule OrangeCmsWeb.Components.Sheet do
  @moduledoc """
  Implement Sheet componet https://ui.shadcn.com/docs/components/sheet

  ## Example:

      <.sheet show>
        <.sheet_trigger target="test">
          <.button variant="outline">open</.button>
        </.sheet_trigger>
        <.sheet_content id="test" side="bottom">
          <.sheet_header>
            <.sheet_title>Edit profile</.sheet_title>
            <.sheet_description>
              Make changes to your profile here. Click save when you're done.
            </.sheet_description>
          </.sheet_header>
          <div class="grid gap-4 py-4">
            <div class="grid grid-cols-4 items-center gap-4">
              <.label for="name" class="text-right">
                Name
              </.label>
              <Input.input id="name" name="name" value="pedro duarte" class="col-span-3" />
            </div>
            <div class="grid grid-cols-4 items-center gap-4">
              <.label for="username" class="text-right">
                Username
              </.label>
              <Input.input id="username" name="username" value="@peduarte" class="col-span-3" />
            </div>
          </div>
          <.sheet_footer>
            <.sheet_close target="test">
              <.button type="submit" phx-click="save">save changes</.button>
            </.sheet_close>
          </.sheet_footer>
        </.sheet_content>
      </.sheet>
  """
  use Phoenix.Component

  import OrangeCmsWeb.Components.ComponentHelpers

  alias Phoenix.LiveView.JS

  attr :show, :boolean, default: false, doc: "Show the sheet on mount"
  attr :class, :string, default: nil
  slot :inner_block, required: true

  def sheet(assigns) do
    # random unique key
    assigns = assign(assigns, :key, generate_id(prefix: "sheet"))

    ~H"""
    <div
      class={[@class]}
      phx-mounted={
        (@show && JS.exec("phx-show-sheet", to: "[data-key=#{@key}] .sheet-content")) || %JS{}
      }
      data-key={@key}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :class, :string, default: "inner-block"
  attr :target, :string, required: true, doc: "The id of the sheet to open"
  slot :inner_block, required: true

  def sheet_trigger(assigns) do
    ~H"""
    <div class={[@class]} phx-click={JS.exec("phx-show-sheet", to: "#" <> @target)}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :class, :string, default: nil

  defp sheet_overlay(assigns) do
    ~H"""
    <div
      class={[
        "sheet-overlay fixed hidden inset-0 z-50 bg-background/80 backdrop-blur-sm",
        @class
      ]}
      aria-hidden="true"
    >
    </div>
    """
  end

  attr :id, :string, required: true, doc: "The id of the sheet"
  attr :class, :string, default: nil
  attr :side, :string, default: "right", values: ~w(left right top bottom), doc: "The side of the sheet"
  slot :inner_block, required: true
  slot :custom_close_btn, required: false

  def sheet_content(assigns) do
    variant_class =
      case assigns.side do
        "left" -> "inset-y-0 left-0 h-full w-3/4 border-r sm:max-w-sm"
        "right" -> "inset-y-0 right-0 h-full w-3/4  border-l sm:max-w-sm"
        "top" -> "inset-x-0 top-0 border-b"
        "bottom" -> "inset-x-0 bottom-0 border-t"
      end

    assigns =
      assign(
        assigns,
        :variant_class,
        variant_class
      )

    ~H"""
    <div
      class="sheet-content relative z-50"
      id={@id}
      phx-show-sheet={show_sheet(@id, @side)}
      phx-hide-sheet={hide_sheet(@id, @side)}
    >
      <.sheet_overlay />
      <.focus_wrap
        id={"sheet-" <> @id}
        phx-window-keydown={JS.exec("phx-hide-sheet", to: "#" <> @id)}
        phx-key="escape"
        phx-click-away={JS.exec("phx-hide-sheet", to: "#" <> @id)}
        role="sheet"
        class={[
          "sheet-content-wrap hidden fixed z-50 bg-background shadow-lg transition",
          @variant_class,
          @class
        ]}
      >
        <div class={["relative h-full"]}>
          <div class={["p-6 overflow-y-auto h-full", @class]}>
            <%= render_slot(@inner_block) %>
          </div>

          <%= if close_btn = render_slot(@custom_close_btn) do %>
            <%= close_btn %>
          <% else %>
            <button
              type="button"
              class="absolute right-4 top-4 rounded-sm opacity-70 ring-offset-background transition-opacity hover:opacity-100 focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 disabled:pointer-events-none"
              phx-click={hide_sheet(@id, @side)}
            >
              <Heroicons.x_mark class="w-4 h-4 no-collapse" />
              <span class="sr-only">Close</span>
            </button>
          <% end %>
        </div>
      </.focus_wrap>
    </div>
    """
  end

  attr :class, :string, default: nil
  slot :inner_block, required: true

  def sheet_header(assigns) do
    ~H"""
    <div class={["flex flex-col space-y-2 text-center sm:text-left", @class]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :class, :string, default: nil
  slot :inner_block, required: true

  def sheet_title(assigns) do
    ~H"""
    <h3 class={["text-lg font-semibold text-foreground", @class]}>
      <%= render_slot(@inner_block) %>
    </h3>
    """
  end

  attr :class, :string, default: nil
  slot :inner_block, required: true

  def sheet_description(assigns) do
    ~H"""
    <p class={["text-sm text-muted-foreground", @class]}>
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  attr :class, :string, default: nil
  slot :inner_block, required: true

  def sheet_footer(assigns) do
    ~H"""
    <div class={["flex flex-col-reverse sm:flex-row sm:justify-end sm:space-x-2", @class]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :class, :string, default: nil
  attr :target, :string, required: true, doc: "The id of the sheet tag to close"
  slot :inner_block, required: true

  def sheet_close(assigns) do
    ~H"""
    <div class={["", @class]} phx-click={JS.exec("phx-hide-sheet", to: "#" <> @target)}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  defp show_sheet(js \\ %JS{}, id, side) when is_binary(id) do
    transition =
      case side do
        "left" -> {"transition ease-in-out", "-translate-x-full", "translate-x-0"}
        "right" -> {"transition ease-in-out", "translate-x-full", "translate-x-0"}
        "top" -> {"transition ease-in-out", "-translate-y-full", "translate-y-0"}
        "bottom" -> {"transition ease-in-out", "translate-y-full", "translate-y-0"}
      end

    js
    |> JS.show(
      to: "##{id} .sheet-overlay",
      transition: {"transition ease-in-out", "opacity-0", "opacity-100"}
    )
    |> JS.show(
      to: "##{id} .sheet-content-wrap",
      transition: transition
    )
    |> JS.add_class("overflow-hidden", to: "body")
    |> JS.focus_first(to: "##{id} .sheet-content-wrap")
  end

  defp hide_sheet(js \\ %JS{}, id, side) do
    transition =
      case side do
        "left" -> {"transition ease-in-out", "translate-x-0", "-translate-x-full"}
        "right" -> {"transition ease-in-out", "translate-x-0", "translate-x-full"}
        "top" -> {"transition ease-in-out", "translate-y-0", "-translate-y-full"}
        "bottom" -> {"transition ease-in-out", "translate-y-0", "translate-y-full"}
      end

    js
    |> JS.hide(
      to: "##{id} .sheet-overlay",
      transition: {"transition ease-in-out", "opacity-100", "opacity-0"}
    )
    |> JS.hide(to: "##{id} .sheet-content-wrap", transition: transition)
    |> JS.remove_class("overflow-hidden", to: "body")
    |> JS.pop_focus()
  end
end
