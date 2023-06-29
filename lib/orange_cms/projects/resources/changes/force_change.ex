defmodule OrangeCms.Projects.Change.ForceChange do
  @moduledoc false
  use Ash.Resource.Change

  import Ash.Changeset, only: [force_change_attributes: 2]

  def change(changeset, changes, _context) do
    force_change_attributes(changeset, changes)
  end
end
