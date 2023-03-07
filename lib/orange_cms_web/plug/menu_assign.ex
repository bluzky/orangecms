defmodule OrangeCmsWeb.MenuAssign do
  @moduledoc """
  Ensures common `assigns` are applied to all LiveViews attaching this hook.
  """
  import Phoenix.LiveView
  alias OrangeCms.Content
  alias OrangeCms.Content.ContentType

  def on_mount(_, _params, _session, socket) do
    ContentType
    |> Ash.Query.for_read(:read)
    |> Content.read()
    |> IO.inspect()
    |> case do
      {:ok, content_types} ->
        {:cont, Phoenix.Component.assign(socket, :content_types, content_types)}

      {:error, err} ->
        {:halt, socket}
    end
  end
end
