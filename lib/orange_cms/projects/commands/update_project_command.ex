defmodule OrangeCms.Projects.UpdateProjectCommand do
  @moduledoc """
  This module is responsible for updating a project.
  """
  use OrangeCms, :command

  alias OrangeCms.Projects.Project

  @spec call(Project.t(), map) :: {:ok, Project.t()} | {:error, term}
  def call(project, attrs) do
    project
    |> Project.changeset(attrs)
    |> Repo.update()
  end
end
