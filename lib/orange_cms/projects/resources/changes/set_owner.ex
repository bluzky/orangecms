defmodule OrangeCms.Projects.Changes.SetOwner do
  @moduledoc false
  use Ash.Resource.Change

  import Ash.Changeset

  @impl true
  def change(changeset, _opts, _context) do
    actor = Ash.get_actor()

    manage_relationship(changeset, :project_users, %{user_id: actor.id, role: :admin, is_owner: true},
      on_no_match: {:create, :create_owner},
      on_match: :ignore,
      authorize?: false
    )
  end
end
