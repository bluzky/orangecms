defmodule OrangeCmsWeb.ContentTypeLive.Edit do
  use OrangeCmsWeb, :live_view

  alias OrangeCms.Content
  alias OrangeCms.Content.ContentType

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    content_type = ContentType.get!(id)

    {:noreply,
     socket
     |> assign(:page_title, "Edit content type")
     |> assign(:content_type, content_type)
     |> assign(
       :form,
       AshPhoenix.Form.for_update(content_type, :update,
         api: Content,
         forms: [
           field_defs: [
             type: :list,
             data: content_type.field_defs,
             resource: Content.FieldDef,
             update_action: :update,
             create_action: :create
           ]
         ]
       )
     )}
  end

  def handle_event("add_field", %{"path" => path}, socket) do
    form = AshPhoenix.Form.add_form(socket.assigns.form, path, params: %{name: "New field"})
    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("remove_field", %{"path" => path}, socket) do
    form = AshPhoenix.Form.remove_form(socket.assigns.form, path)
    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("validate", %{"form" => form_params}, socket) do
    form =
      AshPhoenix.Form.validate(
        socket.assigns.form,
        form_params
      )

    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("save", %{"form" => form_params}, socket) do
    form =
      AshPhoenix.Form.validate(
        socket.assigns.form,
        form_params
      )

    case AshPhoenix.Form.submit(form) do
      {:ok, content_type} ->
        form =
          AshPhoenix.Form.for_update(content_type, :update,
            api: Content,
            forms: [
              field_defs: [
                type: :list,
                data: content_type.field_defs,
                resource: Content.FieldDef,
                update_action: :update,
                create_action: :create
              ]
            ]
          )

        socket =
          socket
          |> assign(form: form)
          |> put_flash(:info, "Update Content type successfully!")

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  def switch_tab(js \\ %JS{}, tab) do
    js
    |> JS.add_class("hidden", to: "#general, #image-settings, #frontmatter")
    |> JS.remove_class("hidden", to: tab)
    |> JS.remove_class("tab-active", to: "#tab-header a")
    |> JS.add_class("tab-active", to: "#{tab}-hd")
  end
end
