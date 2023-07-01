defmodule OrangeCmsWeb.Components.JS do
  alias Phoenix.LiveView.JS

  def toggle_class(js \\ %JS{}, class, to: target) do
    js
    |> JS.remove_class(
      class,
      to: "#{target}.#{class}"
    )
    |> JS.add_class(
      class,
      to: "#{target}:not(.#{class})"
    )
  end
end
