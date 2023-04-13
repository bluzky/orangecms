defmodule OrangeCms.Accounts do
  use Ash.Api

  resources do
    registry(OrangeCms.Accounts.Registry)
  end

  authorization do
    authorize :by_default
  end
end
