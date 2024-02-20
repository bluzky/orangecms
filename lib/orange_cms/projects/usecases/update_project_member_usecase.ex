defmodule OrangeCms.Projects.UpdateProjectMemberUsecase do
  @moduledoc """
  This usecase is for updating a project member
  """
  @spec call(ProjectMember.t(), map) :: {:ok, ProjectMember.t()} | {:error, term}
  def call(member, attrs) do
    OrangeCms.Projects.UpdateProjectMemberCommand.call(member, attrs)
  end
end
