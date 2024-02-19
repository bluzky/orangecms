defmodule OrangeCms.Projects.RemoveProjectMemberUsecase do
  @moduledoc """
  This usecase is for removing a project member
  """
  @spec call(ProjectMember.t()) :: {:ok, ProjectMember.t()} | {:error, term}
  def call(member) do
    OrangeCms.Projects.RemoveProjectMemberCommand.call(member)
  end
end
