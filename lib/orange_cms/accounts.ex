defmodule OrangeCms.Accounts do
  use Ash.Api

  resources do
    registry(OrangeCms.Accounts.Registry)
  end
end
