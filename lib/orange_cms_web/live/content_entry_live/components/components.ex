defmodule OrangeCmsWeb.ContentEntryLive.Components do
  use Phoenix.Component
  alias OrangeCms.Content.FieldDef

  @input_map %{
    "string" => &__MODULE__.string_input/1,
    "text" => &__MODULE__.text_input/1,
    "number" => &__MODULE__.number_input/1,
    "boolean" => &__MODULE__.boolean_input/1,
    "datetime" => &__MODULE__.datetime_input/1,
    "date" => &__MODULE__.date_input/1,
    "select" => &__MODULE__.select/1,
    "checkbox" => &__MODULE__.checkbox/1,
    "upload" => &__MODULE__.upload/1
  }

  def render_input(field_def, value, assigns \\ %{}) do
    func = Map.get(@input_map, to_string(field_def.type)) || @input_map["string"]

    Phoenix.LiveView.HTMLEngine.component(
      func,
      Map.merge(assigns, %{field_def: field_def, value: value}),
      {__ENV__.module, __ENV__.function, __ENV__.file, __ENV__.line}
    )
  end

  attr :field_def, FieldDef, required: true
  slot(:inner_block)

  def input_wrapper(assigns) do
    ~H"""
    <div>
      <label {[for: @field_def.key]} class="block text-xs font-bold text-gray-700">
        <%= @field_def.name || @field_def.key %>
      </label>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :field_def, FieldDef, required: true
  attr :value, :any, default: nil
  attr :options, :map, default: %{}

  def string_input(assigns) do
    ~H"""
    <.input_wrapper {[field_def: @field_def]}>
      <input
        {[id: @field_def.key, value: @value, name: field_name(@field_def, @options)]}
        type="text"
        class="mt-1 w-full rounded-md border-gray-200 shadow-sm sm:text-sm"
      />
    </.input_wrapper>
    """
  end

  def text_input(assigns) do
    ~H"""
    <.input_wrapper {[field_def: @field_def]}>
      <textarea
        {[id: @field_def.key, rows: 3, name: field_name(@field_def, @options)]}
        class="mt-1 w-full rounded-md border-gray-200 shadow-sm sm:text-sm"
      ><%= @value %></textarea>
    </.input_wrapper>
    """
  end

  def number_input(assigns) do
    ~H"""
    <.input_wrapper {[field_def: @field_def]}>
      <input
        {[id: @field_def.key, name: field_name(@field_def, @options), value: @value || @field_def.default_value]}
        type="number"
        class="mt-1 w-full rounded-md border-gray-200 shadow-sm sm:text-sm"
      />
    </.input_wrapper>
    """
  end

  def boolean_input(assigns) do
    ~H"""
    <.input_wrapper {[field_def: @field_def]}>
      <label {[for: @field_def.key]} class="relative h-8 w-14 cursor-pointer block">
        <input type="hidden" name={field_name(@field_def, @options)} value="0" />

        <input
          type="checkbox"
          class="peer sr-only"
          onclick="this.previousSibling.value=1-this.previousSibling.value"
          {[id: @field_def.key, name: field_name(@field_def, @options),checked: @value, value: "1"]}
        />

        <span class="absolute inset-0 rounded-full bg-gray-300 transition peer-checked:bg-green-500">
        </span>

        <span class="absolute inset-0 m-1 h-6 w-6 rounded-full bg-white transition peer-checked:translate-x-6">
        </span>
      </label>
    </.input_wrapper>
    """
  end

  def datetime_input(assigns) do
    ~H"""
    <.input_wrapper {[field_def: @field_def]}>
      <input
        type="datetime-local"
        {[id: @field_def.key, name: field_name(@field_def, @options), value: @value]}
        class="mt-1 w-full rounded-md border-gray-200 shadow-sm sm:text-sm"
      />
    </.input_wrapper>
    """
  end

  def date_input(assigns) do
    ~H"""
    <.input_wrapper {[field_def: @field_def]}>
      <input
        type="date"
        {[id: @field_def.key, name: field_name(@field_def, @options), value: @value]}
        class="mt-1 w-full rounded-md border-gray-200 shadow-sm sm:text-sm"
      />
    </.input_wrapper>
    """
  end

  def select(assigns) do
    ~H"""
    <.input_wrapper {[field_def: @field_def]}>
      <select
        {[id: @field_def.key, name: field_name(@field_def, @options), value: @value]}
        class="mt-1 w-full rounded-md border-gray-200 shadow-sm sm:text-sm"
      >
        <option
          :for={item <- OrangeCms.Content.load!(@field_def, :options) |> Map.get(:options)}
          {[value: item, selected: item == @value]}
        >
          <%= item %>
        </option>
      </select>
    </.input_wrapper>
    """
  end

  def array_input(assigns) do
    ~H"""
    <div>
      <label {[for: @field_def.key]} class="block text-xs font-medium text-gray-700">
        <%= @field_def.name %>
      </label>

      <input
        {[id: @field_def.key, value: @value]}
        type="text"
        class="mt-1 w-full rounded-md border-gray-200 shadow-sm sm:text-sm"
      />
    </div>
    """
  end

  def checkbox(assigns) do
    value =
      if is_list(assigns.value) do
        assigns.value
      else
        []
      end

    assigns = assign(assigns, :value, value)

    ~H"""
    <.input_wrapper {[field_def: @field_def]}>
      <div class="flex flex-wrap gap-4">
        <label
          :for={item <- OrangeCms.Content.load!(@field_def, :options) |> Map.get(:options)}
          {[for: item]}
          class="flex gap-2"
        >
          <input
            type="checkbox"
            {[ name: field_name(@field_def, @options, true), id: item, value: item, checked: Enum.member?(@value, item)]}
            class="h-5 w-5 rounded-md border-gray-200 bg-white shadow-sm"
          />

          <span class="text-sm text-gray-700">
            <%= item %>
          </span>
        </label>
      </div>
    </.input_wrapper>
    """
  end

  def upload(assigns) do
    ~H"""
    <div>
      <label class="block text-xs font-medium text-gray-700">
        <%= @field_def.name %>
      </label>
      <div class="form-control">
        <div
          class="input-group input-group-sm"
          phx-update="ignore"
          {[id: "upload-wrapper-" <> @field_def.key ]}
        >
          <input
            type="text"
            {[for: @field_def.key]}
            {[id: @field_def.key, value: @value, name: field_name(@field_def, @options)]}
            placeholder="paste image link or select image to upload"
            class="input input-sm flex-1"
          />
          <input
            type="file"
            class="hidden"
            accept="image/*"
            {[id: @field_def.key <> "upload"]}
            phx-hook="FileUpload"
            {["data-target": @field_def.key, "data-upload-path": "/app/api/upload_image/#{@project.id}", "data-error-display": @field_def.key <> "-error"]}
          />
          <label class="btn btn-sm btn-square" {[for: @field_def.key <> "upload"]}>
            <Lucideicons.upload_cloud />
          </label>
        </div>
        <label class="label">
          <span class="label-text-alt text-red-500" {[id: @field_def.key <> "-error"]}></span>
        </label>
      </div>
    </div>
    """
  end

  defp field_name(field_def, opts, array? \\ false) do
    suffix = if array?, do: "[]"

    if opts[:prefix] do
      "#{opts[:prefix]}[#{field_def.key}]#{suffix}"
    else
      field_def.key <> suffix
    end
  end
end
