defmodule OrangeCms.Projects.ProjectMemberQuery do
  @moduledoc false
  use OrangeCms, :query

  alias OrangeCms.Projects.Helpers.ProjectMemberQueryBuilder

  @spec list_project_members(project_id :: integer(), filters :: map) :: [ProjectMember.t()]
  def list_project_members(project_id, filters \\ %{}) do
    ProjectMemberQueryBuilder.base_query()
    |> where([p], p.project_id == ^project_id)
    |> Filter.with_filters(filters)
    |> Repo.all()
  end
end
