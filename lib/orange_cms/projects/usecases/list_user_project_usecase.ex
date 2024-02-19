defmodule OrangeCms.Projects.ListUserProjectUsecase do
  @moduledoc """
  This module is responsible for listing a user's projects.
  """

  @spec call(User.t()) :: [Project.t()]
  def call(user) do
    OrangeCms.Projects.ProjectQuery.list_user_projects(user)
  end
end
