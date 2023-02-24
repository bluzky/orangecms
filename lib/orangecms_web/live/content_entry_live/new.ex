defmodule OrangeCmsWeb.ContentEntryLive.New do
  use OrangeCmsWeb, :live_view
  import OrangeCmsWeb.ContentEntryLive.Components

  alias OrangeCms.Content
  alias OrangeCms.Content.ContentType
  alias OrangeCms.Content.ContentEntry

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket, %{
       form: AshPhoenix.Form.for_create(ContentEntry, :create, api: Content)
     })}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    content_entry =
      ContentEntry
      |> Ash.Query.for_read(:by_id, %{id: id})
      |> Content.read_one!()
      |> Content.load!(:content_type)

    {:noreply,
     assign(socket,
       form: AshPhoenix.Form.for_update(content_entry, :update, api: Content),
       content_type: content_entry.content_type
     )}
  end

  def handle_params(params, _uri, socket) do
    content_type_key = params["content_type"]

    content_type =
      ContentType
      |> Ash.Query.for_read(:by_key, %{key: content_type_key})
      |> Content.read_one!()

    {:noreply, assign(socket, content_type: content_type)}
  end

  def handle_event("validate", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)

    # You can also skip errors by setting `errors: false` if you only want to show errors on submit
    # form = AshPhoenix.Form.validate(socket.assigns.form, params, errors: false)

    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("create", _params, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form) do
      {:ok, entry} ->
        {:noreply, assign(socket, form: AshPhoenix.Form.for_update(entry, :update, api: Content))}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end
end
