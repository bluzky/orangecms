defmodule OrangeCms.Projects.MemberRole do
  use Ash.Type.Enum,
    values: [:admin, :editor]
end
