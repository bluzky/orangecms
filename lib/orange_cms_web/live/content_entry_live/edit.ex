defmodule OrangeCmsWeb.ContentEntryLive.Edit do
  use OrangeCmsWeb, :live_view
  import OrangeCmsWeb.ContentEntryLive.Components

  alias OrangeCms.Content
  alias OrangeCms.Content.ContentType
  alias OrangeCms.Content.ContentEntry

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(%{
       form: nil
     })}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    content_entry =
      Content.get_content_entry!(id)
      |> OrangeCms.Repo.preload(:content_type)

    {:noreply,
     assign(socket,
       form: Content.change_content_entry(content_entry),
       content_entry: content_entry,
       content_type: content_entry.content_type
     )}
  end

  def handle_params(params, _uri, socket) do
    content_type_key = params["type"]

    content_type =
      Content.find_content_type(socket.assigns.current_project.id, code: content_type_key)

    {:noreply, assign(socket, content_type: content_type)}
  end

  # save content but not publish
  def handle_event("autosave", %{"frontmatter" => params, "content_entry" => form_params}, socket) do
    case Content.update_content_entry(
           socket.assigns.content_entry,
           Map.merge(form_params, %{
             "frontmatter" => params
           })
         ) do
      {:ok, entry} ->
        {:noreply,
         socket
         |> assign(
           form: Content.change_content_entry(entry),
           content_entry: entry
         )
         |> put_flash(:success, "Auto saved")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: changeset)}
    end
  end

  def handle_event("save", %{"frontmatter" => params, "content_entry" => form_params}, socket) do
    case Content.update_content_entry(
           socket.assigns.content_entry,
           Map.merge(form_params, %{
             "frontmatter" => params
           })
         ) do
      {:ok, entry} ->
        # publish to github

        case OrangeCms.Shared.Github.publish(
               socket.assigns.current_project,
               entry.content_type,
               entry
             ) do
          {:ok, updated_entry} ->
            {:noreply,
             socket
             |> assign(form: Content.change_content_entry(updated_entry))
             |> put_flash(:info, "Published entry successfully!")}

          {:error, _error} ->
            {:noreply,
             socket
             |> assign(form: Content.change_content_entry(entry))
             |> put_flash(:error, "Failed to publish to github!")}
        end

      {:error, changeset} ->
        {:noreply, assign(socket, form: changeset)}
    end
  end

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
