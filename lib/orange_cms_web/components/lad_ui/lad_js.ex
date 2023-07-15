defmodule OrangeCmsWeb.Components.LadUI.LadJS do
  @moduledoc """
  LadJS provide extra functionality to exsiting LiveView JS.
  It implemented using `JS.dispatch` an event named `lad:exec`, all arguments are stored in `event.detail`.

  All LadJS operations are combined in a single `lad:exec` event

  ## LadJS support extended selectors to query DOM elements relative to current element:

  - closest(selector): query the closest parent matching the
  - children(selector): query the children matching the selector

  ## Example selectors:

  - `toggle_class("hidden", to: "closest(.parent-class)")`
  - `toggle_class("hidden", to: "children(.children-class)")`
  """

  alias Phoenix.LiveView.JS

  @doc """
  Enhance all current JS commands to support extended selectors.
  All commands with `to` option will be enhanced.

  Only use this when necessary, it makes your code a bit slower, because it has a longer trip to final execution: LiveView's JS -> Lad's JS -> LiveView's JS.

  To reduce the effect of this, you can use `enhance` only for commands that need it.

  ## Example:

      JS.set_attribute("data-foo", "bar", to: "closest(.parent-class)")
      |> LadJS.enhance()
      |> JS.exec("on-confirm", to: "#some-id")

  Or like this:

      JS.show("#dialog")
      |> LadJS.enhance(JS.hide("closest(.trigger)"))
      |> JS.exec("on-confirm", to: "#some-id")

  In this case it only applies enhancement to `JS.hide("closest(.trigger)")`
  """
  def enhance(%JS{ops: ops}) do
    append_command(%JS{}, "enhance", ops)
  end

  @doc """
  Executes JS commands located in `action` attribute of target element.
  Target element is stored in attr "cb-target" of current element.
  """
  def exec_callback(js \\ %JS{}, action) when is_binary(action) do
    append_command(js, "exec_cb", %{cb: action})
  end

  @doc """
  Toggle attribute value on element. For example you want to toggle attribute `data-state` between `open` and `close`:

      toggle_attribute({"data-state", {"open", "close"}})

  If current value is `open`, it will be changed to `close`, and vice versa. If current value is not set, it will be set to first value in tupple, in this case `open`.

  Value tuple only support 2 values, because it's designed to toggle between 2 states.

  ### Options:

  - `to`: query selector to find target element, default to current element

  """
  def toggle_attribute({attr, values}) when is_binary(attr) do
    toggle_attribute(%JS{}, {attr, values}, [])
  end

  def toggle_attribute({attr, values}, opts) when is_binary(attr) and is_list(opts) do
    toggle_attribute(%JS{}, {attr, values}, opts)
  end

  def toggle_attribute(%JS{} = js, {attr, values}) when is_binary(attr) do
    toggle_attribute(js, {attr, values}, [])
  end

  def toggle_attribute(%JS{} = js, {attr, {_, _} = values}, opts) do
    opts = validate_keys(opts, "toggle_attribute", [:to])

    append_command(
      js,
      "toggle_attr",
      %{
        attr: attr,
        values: Tuple.to_list(values),
        to: opts[:to]
      }
    )
  end

  @doc """
  Toggle class on element.
  """
  def toggle_class(class, opts \\ [])

  def toggle_class(class, opts) when is_binary(class) and is_list(opts) do
    toggle_class(%JS{}, class, opts)
  end

  def toggle_class(%JS{} = js, class) when is_binary(class) do
    toggle_class(js, class, [])
  end

  def toggle_class(%JS{} = js, class, opts) when is_binary(class) and is_list(opts) do
    opts = validate_keys(opts, "toggle_class", [:to])

    append_command(js, "toggle_class", %{
      class: class,
      to: opts[:to]
    })
  end

  # Append command to existing `lad:exec` event
  # If command doesn't exist, it will register new `lad:exec` event
  defp append_command(%JS{} = js, command, args) do
    JS.dispatch(js, "lad:exec", detail: [command, args])
  end

  # borrow from https://github.com/phoenixframework/phoenix_live_view/blob/main/lib/phoenix_live_view/js.ex#L815
  defp validate_keys(opts, kind, allowed_keys) do
    for key <- Keyword.keys(opts) do
      if key not in allowed_keys do
        raise ArgumentError, """
        invalid option for #{kind}
        Expected keys to be one of #{inspect(allowed_keys)}, got: #{inspect(key)}
        """
      end
    end

    opts
  end
end
