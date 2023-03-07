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
     assign(socket, content_entries: content_entries, content_type: content_type
     )}
  end

  def handle_event("create-entry", _params, socket) do
    content_type = socket.assigns.content_type
    ContentEntry
    |> Ash.Changeset.for_create(:create, %{title: "untitled", raw_body: ".", content_type_id: content_type.id})
    |> Content.create
    |> case  do
         {:ok, entry} ->
           {:noreply, push_navigate(socket, to: ~p"/app/content/#{content_type.key}/#{entry.id}")}
         {:error, error} ->
IO.inspect error
           {:noreply, put_flash(socket, :error, "Cannot create new #{content_type.name}")}
       end
  end
end
