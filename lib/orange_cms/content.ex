defmodule OrangeCms.Content do
  use Ash.Api,
    extensions: [
      AshGraphql.Api
    ]

  resources do
    registry(OrangeCms.Content.Registry)
  end

  graphql do
    authorize?(false)
  end

  authorization do
    authorize :by_default
  end
end
