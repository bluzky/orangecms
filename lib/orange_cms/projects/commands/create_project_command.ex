defmodule OrangeCms.Projects.CreateProjectCommand do
  @moduledoc """
  This command create a new project and set the creator as the default and user the owner of the project
  """
  use OrangeCms, :command

  alias OrangeCms.Projects.CreateProjectParams
  alias OrangeCms.Projects.Project
  alias OrangeCms.Value

  def call(%CreateProjectParams{} = params, creator) do
    # add default member
    params =
      params
      |> Value.new()
      |> Map.put(:project_members, [%{user_id: creator.id, role: :admin, is_owner: true}])

    %Project{owner_id: creator.id}
    |> Project.changeset(params)
    |> Project.change_members()
    |> Repo.insert()
  end
end
