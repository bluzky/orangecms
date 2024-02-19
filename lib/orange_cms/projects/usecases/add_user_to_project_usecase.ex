defmodule OrangeCms.Projects.AddUserToProjectUsecase do
  @moduledoc """
  Add a user to a project
  """
  alias OrangeCms.Projects.Project
  alias OrangeCms.Projects.ProjectMember

  @spec call(Project.t(), map) :: {:ok, ProjectMember.t()} | {:error, term}
  def call(project, %{user_id: user_id} = attrs) do
    with {:ok, _user} <- OrangeCms.Accounts.FindUserUsecase.call(id: user_id) do
      OrangeCms.Projects.CreateProjectMemberCommand.call(project, attrs)
    end
  end
end
