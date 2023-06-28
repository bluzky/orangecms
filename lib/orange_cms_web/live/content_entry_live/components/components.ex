defmodule OrangeCmsWeb.ContentEntryLive.Components do
  use Phoenix.Component
  alias OrangeCms.Content.FieldDef

  @input_map %{
    string: "text",
    text: "textarea",
    number: "number",
    boolean: "checkbox",
    datetime: "datetime-local",
    date: "date",
    select: "select"
  }

  attr :field, FieldDef, required: true
  attr :value, :any, default: nil
  attr :data, :map, default: %{}
  attr :rest, :global

  def schema_field(%{field: field} = assigns) do
    assigns
    |> assign(
      id: field.key,
      label: field.name || field.key,
      type: field.type,
      name: field_name(field, assigns.data.options)
    )
    |> render_input()
  end

  attr :field, FieldDef, required: false
  attr :id, :string, default: nil
  attr :label, :string, default: nil
  attr :name, :string, required: true
  attr :type, :atom, required: true
  attr :value, :any, default: nil
  attr :data, :map, default: %{}
  attr :rest, :global

  def render_input(%{type: :select} = assigns) do
    field = OrangeCms.Content.load!(assigns.field, :options)

    assigns =
      assign(assigns, :type, "select")
      |> assign(:assigns, nil)
      |> assign(:field, nil)
      |> assign(:data, nil)
      |> assign(:options, field.options)

    ~H"""
    <OrangeCmsWeb.CoreComponents.input {assigns} />
    """
  end

  def render_input(%{type: :checkbox} = assigns) do
    field = OrangeCms.Content.FieldDef.load(assigns.field, :options)

    value =
      if is_list(assigns.value) do
        assigns.value
      else
        []
      end

    assigns = assign(assigns, value: value, options: field.options)

    ~H"""
    <div class="form-control">
      <OrangeCmsWeb.CoreComponents.label for={@id}><%= @label %></OrangeCmsWeb.CoreComponents.label>
      <div class="flex flex-wrap gap-x-6 gap-y-3">
        <label :for={item <- @options} {[for: item]} class="flex gap-2">
          <input
            type="checkbox"
            class="checkbox"
            {[ name: @name, id: item, value: item, checked: Enum.member?(@value, item)]}
          />

          <span class="text-sm">
            <%= item %>
          </span>
        </label>
      </div>
    </div>
    """
  end

  def render_input(%{type: :upload} = assigns) do
    preview_url =
      if assigns.value do
        "/assets/preview/#{assigns.data.entry.project_id}/#{assigns.data.entry.content_type_id}?path=#{assigns.value}"
      end

    assigns = assign(assigns, :preview_url, preview_url)

    ~H"""
    <div>
      <label class="block text-xs font-medium text-gray-700">
        <%= @label %>
      </label>
      <div class="form-control">
        <div class="input-group input-group-sm" phx-update="ignore" {[id: "upload-wrapper-" <> @id ]}>
          <input
            type="text"
            {[for: @id]}
            {[id: @id, value: @value, name: @name]}
            placeholder="paste image link or select image to upload"
            class="input input-sm flex-1"
          />
          <input
            type="file"
            class="hidden"
            accept="image/*"
            {[id: @id <> "upload"]}
            phx-hook="FileUpload"
            {["data-target": @id, "data-preview": @id <> "-preview", "data-upload-path": "/api/upload_image/#{@data.entry.project_id}/#{@data.entry.content_type_id}",
              "data-error-display": @id <> "-error"]}
          />
          <label class="btn btn-sm btn-square" {[for: @id <> "upload"]}>
            <Heroicons.arrow_up_tray class="w-4 h-4" />
          </label>
        </div>
        <label class="label">
          <span class="label-text-alt text-red-500" {[id: @id <> "-error"]}></span>
        </label>
        <div class="w-full h-24 border border-dashed flex items-center justify-center text-gray-300 overflow-hidden">
          <img {[id: @id <> "-preview", src: @preview_url]} alt="image preview" />
        </div>
      </div>
    </div>
    """
  end

  def render_input(assigns) do
    input_type = @input_map[assigns.type] || "text"

    assigns =
      assign(assigns, :type, input_type)
      |> assign(:assigns, nil)
      |> assign(:data, nil)
      |> assign(:field, nil)

    ~H"""
    <OrangeCmsWeb.CoreComponents.input {assigns} />
    """
  end

  defp field_name(field_def, opts) do
    suffix = if field_def.type == :checkbox, do: "[]", else: ""

    if opts[:prefix] do
      "#{opts[:prefix]}[#{field_def.key}]#{suffix}"
    else
      field_def.key <> suffix
    end
  end
end
