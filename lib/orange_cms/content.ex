defmodule OrangeCms.Content do
  use Ash.Api

  resources do
    registry(OrangeCms.Content.Registry)
  end
end
