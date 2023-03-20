defmodule OrangeCmsWeb.ContentEntryLive.Edit do
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
    content_type_key = params["type"]

    content_type =
      ContentType
      |> Ash.Query.for_read(:by_key, %{key: content_type_key})
      |> Content.read_one!()

    {:noreply, assign(socket, content_type: content_type)}
  end

  def handle_event("validate", %{"frontmatter" => params, "form" => form_params}, socket) do
    form =
      AshPhoenix.Form.validate(
        socket.assigns.form,
        Map.merge(form_params, %{
          frontmatter: params,
          content_type_id: socket.assigns.content_type.id
        })
      )

    # You can also skip errors by setting `errors: false` if you only want to show errors on submit
    # form = AshPhoenix.Form.validate(socket.assigns.form, params, errors: false)

    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("save", %{"frontmatter" => params, "form" => form_params}, socket) do
    form =
      AshPhoenix.Form.validate(
        socket.assigns.form,
        Map.merge(form_params, %{
          frontmatter: params,
          content_type_id: socket.assigns.content_type.id
        })
      )

    case AshPhoenix.Form.submit(form) do
      {:ok, entry} ->
        # publish to github

        case OrangeCms.Shared.Github.publish(entry, socket.assigns.current_project) do
          {:ok, new_entry} ->
            {:noreply,
             socket
             |> assign(form: AshPhoenix.Form.for_update(new_entry, :update, api: Content))
             |> put_flash(:info, "Published entry successfully!")}

          {:error, _error} ->
            {:noreply,
             socket
             |> assign(form: AshPhoenix.Form.for_update(entry, :update, api: Content))
             |> put_flash(:error, "Failed to publish to github!")}
        end

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end
end
