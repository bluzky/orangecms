defmodule OrangeCmsWeb.Components.LadUI.AlertDialog do
  @moduledoc """
  Implement of card components from https://ui.shadcn.com/docs/components/card
  """
  use OrangeCmsWeb.Components.LadUI, :component

  import OrangeCmsWeb.Components.LadUI.Button

  attr :id, :string, required: true
  attr :class, :string, default: nil
  slot :inner_block, required: true

  def alert_dialog(assigns) do
    ~H"""
    <div
      class={["alert-dialog-root", @class]}
      id={@id}
      hide-alert={
        JS.set_attribute({"data-state", "closed"}, to: "##{@id} .alert-content")
        |> JS.hide(
          transition: {"transition", "opacity-100", "opacity-0"},
          to: "children(.alert-content-wrapper)"
        )
        |> LadJS.enhance()
      }
      show-alert={
        JS.set_attribute({"data-state", "open"}, to: "##{@id} .alert-content")
        |> JS.show(
          transition: {"transition", "opacity-0", "opacity-100"},
          to: "children(.alert-content-wrapper)"
        )
        |> LadJS.enhance()
      }
      on-cancel={JS.exec("hide-alert")}
      on-confirm={JS.exec("hide-alert") |> LadJS.exec_callback("on-confirm")}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :id, :string, default: nil
  attr :target, :string, default: nil
  attr :class, :string, default: nil
  attr :on_confirm, JS, default: nil
  slot :inner_block, required: true

  def alert_dialog_trigger(assigns) do
    target = assigns.target || "closest(.alert-dialog-root)"

    action =
      if assigns.on_confirm && assigns.id do
        "show-alert"
        |> JS.exec(to: target)
        |> JS.set_attribute({"cb-target", "##{assigns.id}"}, to: target)
        |> LadJS.enhance()
      else
        "show-alert"
        |> JS.exec(to: target)
        |> LadJS.enhance()
      end

    assigns = assign(assigns, target: target, action: action)

    ~H"""
    <div class={["", @class]} id={@id} phx-click={@action} on-confirm={@on_confirm}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :class, :string, default: nil
  slot :inner_block, required: true

  def alert_dialog_content(assigns) do
    ~H"""
    <div class="alert-content-wrapper relative hidden">
      <.alert_dialog_overlay />
      <div
        class="min-w-screen fixed inset-0 z-50 flex min-h-screen items-center justify-center overflow-y-auto"
        role="dialog"
        aria-modal="true"
        tabindex="0"
      >
        <.focus_wrap
          id={generate_id(prefix: "alert-")}
          class={[
            "alert-content fixed left-[50%] top-[50%] z-50 grid w-full max-w-lg translate-x-[-50%] translate-y-[-50%] gap-4 border bg-background p-6 shadow-lg duration-200 data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95 data-[state=closed]:slide-out-to-left-1/2 data-[state=closed]:slide-out-to-top-[48%] data-[state=open]:slide-in-from-left-1/2 data-[state=open]:slide-in-from-top-[48%] sm:rounded-lg md:w-full",
            @class
          ]}
          data-state="closed"
        >
          <%= render_slot(@inner_block) %>
        </.focus_wrap>
      </div>
    </div>
    """
  end

  attr :class, :string, default: nil
  slot :inner_block, required: true

  def alert_dialog_header(assigns) do
    ~H"""
    <div class={["flex flex-col space-y-2 text-center sm:text-left", @class]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :class, :string, default: nil
  slot :inner_block, required: true

  def alert_dialog_footer(assigns) do
    ~H"""
    <div class={["flex flex-col-reverse sm:flex-row sm:justify-end sm:space-x-2", @class]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :class, :string, default: nil
  slot :inner_block, required: true

  def alert_dialog_title(assigns) do
    ~H"""
    <h2 class={["text-lg font-semibold", @class]}>
      <%= render_slot(@inner_block) %>
    </h2>
    """
  end

  attr :class, :string, default: nil
  slot :inner_block, required: true

  def alert_dialog_description(assigns) do
    ~H"""
    <p class={["text-sm text-muted-foreground", @class]}>
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  attr :class, :string, default: nil
  slot :inner_block, required: true

  def alert_dialog_action(assigns) do
    ~H"""
    <.button
      class={Enum.join(["mt-2 sm:mt-0", @class], " ")}
      phx-click={JS.exec("on-confirm", to: "closest(.alert-dialog-root)") |> LadJS.enhance()}
    >
      <%= render_slot(@inner_block) %>
    </.button>
    """
  end

  attr :class, :string, default: nil
  slot :inner_block, required: true

  def alert_dialog_cancel(assigns) do
    ~H"""
    <.button
      class={Enum.join(["mt-2 sm:mt-0", @class])}
      variant="outline"
      phx-click={JS.exec("on-cancel", to: "closest(.alert-dialog-root)") |> LadJS.enhance()}
    >
      <%= render_slot(@inner_block) %>
    </.button>
    """
  end

  def alert_dialog_overlay(assigns) do
    ~H"""
    <div class="sheet-overlay bg-background/80 fixed inset-0 z-50 backdrop-blur-sm" aria-hidden="true">
    </div>
    """
  end
end
