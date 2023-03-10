defmodule OrangeCms.Content.FieldType do
  use Ash.Type.Enum,
    values: [:string, :text, :number, :boolean, :datetime, :select, :array, :checkbox, :upload]
end
