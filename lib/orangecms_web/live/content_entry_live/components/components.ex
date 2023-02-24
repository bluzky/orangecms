defmodule OrangeCmsWeb.ContentEntryLive.Components do
  use Phoenix.Component
  alias OrangeCms.Content.FieldDef

  @input_map %{
    "string" => &__MODULE__.string_input/1,
    "text" => &__MODULE__.text_input/1,
    "number" => &__MODULE__.number_input/1,
    "boolean" => &__MODULE__.boolean_input/1,
    "datetime" => &__MODULE__.datetime_input/1,
    "select" => &__MODULE__.select/1,
    "checkbox" => &__MODULE__.checkbox/1
  }

  def render(field_def, value, assigns \\ %{}) do
    func = Map.get(@input_map, field_def.type) || @input_map["string"]

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
    <%= @field_def.name %>
    </label>
    <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :field_def, FieldDef, required: true
  attr :value, :any, default: nil

  def string_input(assigns) do
    ~H"""
    <.input_wrapper {[field_def: @field_def]}>
    <input
    {[id: @field_def.key, value: @value]}
    type="text"
    class="mt-1 w-full rounded-md border-gray-200 shadow-sm sm:text-sm"
    />
    </.input_wrapper>

    """
  end

  attr :field_def, FieldDef, required: true
  attr :value, :any, default: nil
  attr :rows, :integer, default: 3

  def text_input(assigns) do
    ~H"""
    <.input_wrapper {[field_def: @field_def]}>
    <textarea
    {[id: @field_def.key, value: @value, rows: @rows]}
    class="mt-1 w-full rounded-md border-gray-200 shadow-sm sm:text-sm"
    ></textarea>
    </.input_wrapper>
    """
  end

  attr :field_def, FieldDef, required: true
  attr :value, :any, default: nil

  def number_input(assigns) do
    ~H"""
    <.input_wrapper {[field_def: @field_def]}>
    <input
    {[id: @field_def.key, value: @value || @field_def.default_value]}
    type="number"
    class="mt-1 w-full rounded-md border-gray-200 shadow-sm sm:text-sm"
    />
    </.input_wrapper>

    """
  end

  attr :field_def, FieldDef, required: true
  attr :value, :any, default: nil

  def boolean_input(assigns) do
    ~H"""
    <.input_wrapper {[field_def: @field_def]}>
    <label {[for: @field_def.key]} class="relative h-8 w-14 cursor-pointer block">
    <input type="checkbox" class="peer sr-only"  {[id: @field_def.key, checked: @value]}/>

    <span
    class="absolute inset-0 rounded-full bg-gray-300 transition peer-checked:bg-green-500"
    ></span>

    <span
    class="absolute inset-0 m-1 h-6 w-6 rounded-full bg-white transition peer-checked:translate-x-6"
    ></span>
    </label>
    </.input_wrapper>
    """
  end

  attr :field_def, FieldDef, required: true
  attr :value, :any, default: nil

  def datetime_input(assigns) do
    ~H"""
    <.input_wrapper {[field_def: @field_def]}>
    <input type="datetime-local" {[id: @field_def.key, name: @field_def.key, value: @value]}     class="mt-1 w-full rounded-md border-gray-200 shadow-sm sm:text-sm"
    />
    </.input_wrapper>
    """
  end

  attr :field_def, FieldDef, required: true
  attr :value, :any, default: nil

  def select(assigns) do
    ~H"""
    <.input_wrapper {[field_def: @field_def]}>
      <select {[id: @field_def.key, name: @field_def.key, value: @value]}     class="mt-1 w-full rounded-md border-gray-200 shadow-sm sm:text-sm" >
        <option :for={item <- @field_def.options} {[value: item, selected: item == @value]}>
                <%= item %>
        </option>
      </select>
    </.input_wrapper>
    """
  end

  attr :field_def, FieldDef, required: true
  attr :value, :any, default: nil

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

  attr :field_def, FieldDef, required: true
  attr :value, :any, default: nil

  def checkbox(assigns) do
    ~H"""
    <.input_wrapper {[field_def: @field_def]}>
      <div class="flex gap-4">
      <label :for={item <- @field_def.options} {[for: item]} class="flex gap-2">
              <input
                type="checkbox"
                {[name: @field_def.key, id: item, value: item]}
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

  attr :field_def, FieldDef, required: true
  attr :value, :any, default: nil

  def upload_input(assigns) do
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
end
