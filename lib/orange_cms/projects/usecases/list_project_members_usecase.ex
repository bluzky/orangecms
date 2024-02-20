defmodule OrangeCms.Projects.ListProjectMembersUsecase do
  @moduledoc """
  This usecase is for listing project members
  """
  @spec call(term(), map()) :: [ProjectMember.t()]
  def call(project_id, filters \\ %{}) do
    OrangeCms.Projects.ProjectMemberQuery.list_project_members(project_id, filters)
  end
end
