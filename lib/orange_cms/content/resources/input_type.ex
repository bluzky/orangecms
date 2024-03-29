defmodule OrangeCms.Content.InputType do
  @moduledoc false
  def values do
    [
      :string,
      :text,
      :number,
      :boolean,
      :datetime,
      :date,
      :select,
      :array,
      :checkbox,
      :upload
    ]
  end

  @default_stored_type :string
  @stored_type_map [
    string: :string,
    text: :string,
    number: :integer,
    boolean: :boolean,
    datetime: :naive_datetime,
    date: :date,
    select: :string,
    array: {:array, :string},
    checkbox: {:array, :string},
    upload: :string
  ]
  def stored_type(type) do
    @stored_type_map[type] || @default_stored_type
  end
end
