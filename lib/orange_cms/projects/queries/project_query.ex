defmodule OrangeCms.Projects.ProjectQuery do
  @moduledoc """
  This provide queries for project
  """
  use OrangeCms, :query

  alias OrangeCms.Projects.Project

  @doc """
  List all project that user was assigned
  """
  def list_user_projects(user, filters \\ %{}) do
    query =
      from(p in Project,
        join: pm in assoc(p, :project_members),
        where: pm.user_id == ^user.id,
        order_by: [asc: p.name]
      )

    query
    |> Filter.with_filters(filters)
    |> Repo.all()
  end
end
