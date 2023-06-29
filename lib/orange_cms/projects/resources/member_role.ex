defmodule OrangeCms.Projects.MemberRole do
  @moduledoc false
  use Ash.Type.Enum,
    values: [:admin, :editor]
end
