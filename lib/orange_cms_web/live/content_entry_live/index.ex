defmodule OrangeCmsWeb.ContentEntryLive.Index do
  use OrangeCmsWeb, :live_view

  alias OrangeCms.Content
  alias OrangeCms.Content.ContentType
  alias OrangeCms.Content.ContentEntry

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       type: nil
     )}
  end

  def handle_params(%{"type" => type}, _uri, socket) do

    content_type =
      ContentType
      |> Ash.Query.for_read(:by_key, %{key: type})
      |> Content.read_one!()

    content_entries =
      ContentEntry
      |> Ash.Query.for_read(:by_type, %{content_type_id: content_type.id})
      |> Content.read!()

    {:noreply,
     assign(socket, content_entries: content_entries
     )}
  end
end
