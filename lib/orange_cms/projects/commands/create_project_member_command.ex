defmodule OrangeCms.Projects.CreateProjectMemberCommand do
  @moduledoc """
  Create project member command
  """
  use OrangeCms, :command

  alias OrangeCms.Projects.ProjectMember

  @spec call(Project.t(), map) :: {:ok, ProjectMember.t()} | {:error, term}
  def call(project, attrs) do
    %ProjectMember{project_id: project.id}
    |> ProjectMember.changeset(attrs)
    |> Repo.insert()
  end
end
