defmodule OrangeCms.Projects.CreateProjectCommand do
  @moduledoc """
  This command create a new project and set the creator as the default and user the owner of the project
  """
  use OrangeCms, :command

  alias OrangeCms.Projects.Project

  def call(attrs, creator) do
    # add default member
    attrs = Map.put(attrs, :project_members, [%{user_id: creator.id, role: :admin, is_owner: true}])

    %Project{owner_id: creator.id}
    |> Project.changeset(attrs)
    |> Project.change_members()
    |> Repo.insert()
  end
end
