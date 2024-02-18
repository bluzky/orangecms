defmodule OrangeCms.Projects.CreateProjectUsecase do
  @moduledoc """
  This usecase is for creating a new project
  Create a project with given params
  Add creator as the project owner
  """

  def call(attrs) do
    actor = OrangeCms.get_actor()

    attrs
    |> OrangeCms.Projects.CreateProjectCommand.call(actor)
    |> handle_result()
  end

  defp handle_result({:error, changeset}), do: {:error, changeset}
  defp handle_result({:ok, project}), do: {:ok, project}
end
