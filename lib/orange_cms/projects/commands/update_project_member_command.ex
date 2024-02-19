defmodule OrangeCms.Projects.UpdateProjectMemberCommand do
  @moduledoc """
  Update project member command
  """
  use OrangeCms, :command

  alias OrangeCms.Projects.ProjectMember

  @spec call(ProjectMember.t(), map) :: {:ok, ProjectMember.t()} | {:error, term}
  def call(member, attrs) do
    member
    |> ProjectMember.changeset(attrs)
    |> Repo.update()
  end
end
