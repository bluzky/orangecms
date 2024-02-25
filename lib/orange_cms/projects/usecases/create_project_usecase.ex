defmodule OrangeCms.Projects.CreateProjectUsecase do
  @moduledoc """
  This usecase is for creating a new project
  Create a project with given params
  Add creator as the project owner
  """
  alias OrangeCms.Projects.CreateProjectParams

  def call(params, %{actor: actor} = _context) do
    with {:ok, parsed_params} <- CreateProjectParams.cast(params),
         {:ok, project} <- OrangeCms.Projects.CreateProjectCommand.call(parsed_params, actor) do
      {:ok, project}
    else
      {:error, error} -> {:error, error}
    end
  end
end
