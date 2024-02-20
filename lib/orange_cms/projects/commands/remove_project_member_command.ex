defmodule OrangeCms.Projects.RemoveProjectMemberCommand do
  @moduledoc """
  Remove project member command
  """
  use OrangeCms, :command

  alias OrangeCms.Projects.ProjectMember

  @spec call(ProjectMember.t()) :: {:ok, ProjectMember.t()} | {:error, term}
  def call(member) do
    Repo.delete(member)
  end
end
