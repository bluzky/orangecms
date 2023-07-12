defmodule OrangeCmsWeb.Components.LadJS do
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

  def toggle_attribute(attr, values) when is_binary(attr) do
    toggle_attribute(%JS{}, attr, values, [])
  end

  def toggle_attribute(attr, values, opts) when is_binary(attr) and is_list(opts) do
    toggle_attribute(%JS{}, attr, values, opts)
  end

  def toggle_attribute(%JS{} = js, attr, values) when is_binary(attr) do
    toggle_attribute(js, attr, values, [])
  end

  def toggle_attribute(%JS{} = js, attr, {_, _} = values, opts) do
    opts = validate_keys(opts, "toggle_attribute", [:to])

    command = [
      "toggle_attribute",
      %{
        attr: attr,
        values: Tuple.to_list(values),
        to: opts[:to]
      }
    ]

    append_command(js, command)
  end

  @doc """
  Executes JS commands located in element attributes.

  Similar to `JS.exec` but it support extended Lad's selector
  """

  def exec(attr, opts \\ [])

  def exec(attr, opts) when is_binary(attr) and is_list(opts) do
    exec(%JS{}, attr, opts)
  end

  def exec(%JS{} = js, attr) when is_binary(attr) do
    exec(js, attr, [])
  end

  def exec(%JS{} = js, attr, opts) when is_binary(attr) and is_list(opts) do
    opts = validate_keys(opts, "exec", [:to])

    command = [
      "exec",
      %{
        attr: attr,
        to: opts[:to]
      }
    ]

    append_command(js, command)
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

    command = [
      "toggle_class",
      %{
        class: class,
        to: opts[:to]
      }
    ]

    append_command(js, command)
  end

  # Append command to existing `lad:exec` event
  # If command doesn't exist, it will register new `lad:exec` event
  defp append_command(%JS{ops: ops} = js, command) do
    # find and update existing lad:exec event
    {ops, appended} =
      Enum.reduce(ops, {[], false}, fn op, {acc, appended} ->
        with false <- appended,
             ["dispatch", %{event: "lad:exec", detail: commands} = args] <- op do
          op = ["dispatch", %{args | detail: commands ++ [command]}]
          {[op | acc], true}
        else
          _ ->
            {[op | acc], appended}
        end
      end)

    # if command is not appended, it means `lad:exec` event has not been registered, then register new dispatch event
    if not appended do
      JS.dispatch(%{js | ops: ops}, "lad:exec", detail: [command])
    else
      %{js | ops: ops}
    end
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
