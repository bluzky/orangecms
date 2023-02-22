defmodule OrangeCms.Content.Registry do
  use Ash.Registry,
    extensions: [
      # This extension adds helpful compile time validations
      Ash.Registry.ResourceValidations
    ]

  entries do
    entry OrangeCms.Content.ContentType
    entry OrangeCms.Content.ContentEntry
  end
end
