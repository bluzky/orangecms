defmodule OrangeCmsWeb.Components.LadUI.Dialog do
  @moduledoc """
  Implement of card components from https://ui.shadcn.com/docs/components/card
  """
  use OrangeCmsWeb.Components.LadUI, :component

  @doc """
  Card component

  ## Examples:

        <.dialog :if={@live_action in [:new, :edit]} id="pro-dialog" show on_cancel={JS.navigate(~p"/p")}>
          <.dialog_content class="sm:max-w-[425px]">
            <.dialog_header>
              <.dialog_title>Edit profile</.dialog_title>
              <.dialog_description>
                Make changes to your profile here click save when you're done
              </.dialog_description>
            </.dialog_header>
              <div class_name="grid gap-4 py-4">
                <div class_name="grid grid-cols_4 items-center gap-4">
                  <.label for="name" class-name="text-right">
                    name
                  </.label>
                  <input id="name" value="pedro duarte" class-name="col-span-3" />
                </div>
                <div class="grid grid-cols-4 items_center gap-4">
                  <.label for="username" class="text-right">
                    username
                  </.label>
                  <input id="username" value="@peduarte" class="col-span-3" />
                </div>
              </div>
              <.dialog_footer>
                <.button type="submit">save changes</.button>
              </.dialog_footer>
              </.dialog_content>
        </.dialog>
  """
  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :on_cancel, JS, default: %JS{}
  attr :class, :string, default: nil
  slot :inner_block, required: true

  def dialog(assigns) do
    ~H"""
    <div
      id={@id}
      phx-mounted={@show && show_modal(@id)}
      phx-remove={hide_modal(@id)}
      class="relative z-50 hidden"
    >
      <div
        id={"#{@id}-bg"}
        class="bg-background/80 fixed inset-0 backdrop-blur-sm transition-opacity"
        aria-hidden="true"
      />
      <div
        class="fixed inset-0 flex items-center justify-center overflow-y-auto"
        aria-labelledby={"#{@id}-title"}
        aria-describedby={"#{@id}-description"}
        role="dialog"
        aria-modal="true"
        tabindex="0"
      >
        <.focus_wrap
          id={"#{@id}-wrap"}
          phx-window-keydown={hide_modal(@on_cancel, @id)}
          phx-key="escape"
          phx-click-away={hide_modal(@on_cancel, @id)}
          class="w-full sm:max-w-[425px]"
        >
          <div
            role="dialog"
            class={classes([
              "relative z-50 grid w-full max-w-lg gap-4 border bg-background p-6 shadow-lg duration-200 sm:rounded-lg",
              @class
            ])}
          >
            <%= render_slot(@inner_block) %>

            <button
              type="button"
              class="ring-offset-background absolute top-4 right-4 rounded-sm opacity-70 transition-opacity hover:opacity-100 focus:ring-ring focus:outline-none focus:ring-2 focus:ring-offset-2 disabled:pointer-events-none"
              phx-click={hide_modal(@on_cancel, @id)}
            >
              <Heroicons.x_mark class="no-collapse h-4 w-4" />
              <span class="sr-only">Close</span>
            </button>
          </div>
        </.focus_wrap>
      </div>
    </div>
    """
  end

  attr :class, :string, default: nil
  slot :inner_block, required: true

  def dialog_content(assigns) do
    ~H"""
    <%= render_slot(@inner_block) %>
    """
  end

  attr :class, :string, default: nil
  slot :inner_block, required: true

  def dialog_header(assigns) do
    ~H"""
    <div class={classes(["flex flex-col space-y-1.5 text-center sm:text-left", @class])}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :class, :string, default: nil
  slot :inner_block, required: true

  def dialog_title(assigns) do
    ~H"""
    <h3 class={classes(["text-lg font-semibold leading-none tracking-tight", @class])}>
      <%= render_slot(@inner_block) %>
    </h3>
    """
  end

  attr :class, :string, default: nil
  slot :inner_block, required: true

  def dialog_description(assigns) do
    ~H"""
    <p class={classes(["text-sm text-muted-foreground", @class])}>
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  attr :class, :string, default: nil
  slot :inner_block, required: true

  def dialog_footer(assigns) do
    ~H"""
    <div class={classes(["flex flex-col-reverse sm:flex-row sm:justify-end sm:space-x-2", @class])}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  defp show(js, selector) do
    JS.show(js,
      to: selector,
      transition:
        {"transition-all transform ease-out duration-300", "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  defp hide(js, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all transform ease-in duration-200", "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end

  defp show_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.show(to: "##{id}")
    |> JS.show(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-out duration-300", "opacity-0", "opacity-100"}
    )
    |> show("##{id}-wrap")
    |> JS.add_class("overflow-hidden", to: "body")
    |> JS.focus_first(to: "##{id}-content")
  end

  defp hide_modal(js \\ %JS{}, id) do
    js
    |> JS.hide(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-in duration-200", "opacity-100", "opacity-0"}
    )
    |> hide("##{id}-wrap")
    |> JS.hide(to: "##{id}", transition: {"block", "block", "hidden"})
    |> JS.remove_class("overflow-hidden", to: "body")
    |> JS.pop_focus()
  end
end
