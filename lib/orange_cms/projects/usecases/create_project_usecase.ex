defmodule OrangeCms.Projects.CreateProjectUsecase do
  @moduledoc """
  This usecase is for creating a new project
  Create a project with given params
  Add creator as the project owner
  """
  alias OrangeCms.Projects.CreateProjectParams

  @spec call(CreateProjectParams.t(), OrangeCms.Accounts.User.t()) ::
          {:ok, OrangeCms.Projects.Project.t()} | {:error, Ecto.Changeset.t()}
  def call(%CreateProjectParams{} = params, %{actor: actor}) do
    with :ok <- Skema.validate(params, CreateProjectParams) do
      params
      |> OrangeCms.Projects.CreateProjectCommand.call(actor)
      |> handle_result()
    end
  end

  defp handle_result({:error, changeset}), do: {:error, changeset}
  defp handle_result({:ok, project}), do: {:ok, project}
end
