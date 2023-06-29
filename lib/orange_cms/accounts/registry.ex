defmodule OrangeCms.Accounts.Registry do
  @moduledoc false
  use Ash.Registry,
    extensions: [
      Ash.Registry.ResourceValidations
    ]

  entries do
    entry(OrangeCms.Accounts.OUser)
  end
end
