defmodule OrangeCms.Projects.ListMyProjectUsecase do
  @moduledoc """
  This module is responsible for listing a user's projects.
  """

  @spec call(User.t()) :: [Project.t()]
  def call(user) do
    OrangeCms.Projects.ProjectQuery.list_my_projects(user)
  end
end
