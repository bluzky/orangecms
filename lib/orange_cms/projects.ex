defmodule OrangeCms.Projects do
  @moduledoc false
  use OrangeCms, :context

  alias OrangeCms.Projects.Project
  # TODO: update query for my project
  # TODO: find proper way to get actor
  alias OrangeCms.Projects.ProjectMember

  @doc """
  Returns the list of projects.

  ## Examples

      iex> list_projects()
      [%Project{}, ...]

  """
  def list_my_projects do
    actor = OrangeCms.get_actor()

    query =
      from(p in Project,
        join: pm in assoc(p, :project_members),
        where: pm.user_id == ^actor.id,
        order_by: [asc: p.name]
      )

    Repo.all(query)
  end

  @doc """
  Gets a single project.

  Raises `Ecto.NoResultsError` if the Project does not exist.

  ## Examples

      iex> get_project!(123)
      %Project{}

      iex> get_project!(456)
      ** (Ecto.NoResultsError)

  """
  def get_project!(id), do: Repo.get!(Project, id)

  @doc """
  Creates a project.

  ## Examples

      iex> create_project(%{field: value})
      {:ok, %Project{}}

      iex> create_project(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project(attrs \\ %{}) do
    actor = OrangeCms.get_actor()

    # add default member
    attrs = Map.put(attrs, "project_members", [%{user_id: actor.id, role: :admin, is_owner: true}])

    %Project{owner_id: actor.id}
    |> Project.changeset(attrs)
    |> Project.change_members()
    |> Repo.insert()
  end

  @doc """
  Updates a project.

  ## Examples

      iex> update_project(project, %{field: new_value})
      {:ok, %Project{}}

      iex> update_project(project, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_project(%Project{} = project, attrs) do
    project
    |> Project.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a project.

  ## Examples

      iex> delete_project(project)
      {:ok, %Project{}}

      iex> delete_project(project)
      {:error, %Ecto.Changeset{}}

  """
  def delete_project(%Project{} = project) do
    Repo.delete(project)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project changes.

  ## Examples

      iex> change_project(project)
      %Ecto.Changeset{data: %Project{}}

  """
  def change_project(%Project{} = project, attrs \\ %{}) do
    Project.changeset(project, attrs)
  end

  @doc """
  Returns the list of project_members.

  ## Examples

      iex> list_project_members()
      [%ProjectMember{}, ...]

  """
  def list_project_members(project) do
    ProjectMember
    |> Filtery.filter(:project_id, project.id)
    |> Repo.all()
    |> Repo.preload(:user)
  end

  @doc """
  Gets a single project_member.

  Raises `Ecto.NoResultsError` if the Project user does not exist.

  ## Examples

      iex> get_project_member!(123)
      %ProjectMember{}

      iex> get_project_member!(456)
      ** (Ecto.NoResultsError)

  """
  def get_project_member!(id), do: Repo.get!(ProjectMember, id)

  @doc """
  Creates a project_member.

  ## Examples

      iex> create_project_member(%{field: value})
      {:ok, %ProjectMember{}}

      iex> create_project_member(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project_member(attrs \\ %{}) do
    %ProjectMember{}
    |> ProjectMember.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a project_member.

  ## Examples

      iex> update_project_member(project_member, %{field: new_value})
      {:ok, %ProjectMember{}}

      iex> update_project_member(project_member, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_project_member(%ProjectMember{} = project_member, attrs) do
    project_member
    |> ProjectMember.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a project_member.

  ## Examples

      iex> delete_project_member(project_member)
      {:ok, %ProjectMember{}}

      iex> delete_project_member(project_member)
      {:error, %Ecto.Changeset{}}

  """
  def delete_project_member(%ProjectMember{} = project_member) do
    Repo.delete(project_member)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project_member changes.

  ## Examples

      iex> change_project_member(project_member)
      %Ecto.Changeset{data: %ProjectMember{}}

  """
  def change_project_member(%ProjectMember{} = project_member, attrs \\ %{}) do
    ProjectMember.changeset(project_member, attrs)
  end
end
