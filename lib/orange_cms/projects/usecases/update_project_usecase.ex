defmodule OrangeCms.Projects.UpdateProjectUsecase do
  @moduledoc """
  This usecase is for updating a project
  """
  @spec call(Project.t(), map) :: {:ok, Project.t()} | {:error, term}
  def call(project, attrs) do
    OrangeCms.Projects.UpdateProjectCommand.call(project, attrs)
  end
end
