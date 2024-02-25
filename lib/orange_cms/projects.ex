defmodule OrangeCms.Projects do
  @moduledoc false
  use OrangeCms, :context

  alias OrangeCms.Context
  alias OrangeCms.Projects.Project
  alias OrangeCms.Projects.ProjectMember

  @doc """
  Returns the list of projects.

  ## Examples

      iex> list_user_projects()
      [%Project{}, ...]

  """
  def list_user_projects(user) do
    OrangeCms.Projects.ListUserProjectUsecase.call(user)
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
  @spec create_project(map, Context.t()) :: {:ok, Project.t()} | {:error, Ecto.Changeset.t()}
  def create_project(attrs, context) do
    OrangeCms.Projects.CreateProjectUsecase.call(attrs, context)
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
    OrangeCms.Projects.UpdateProjectUsecase.call(project, attrs)
  end

  @doc """
  List all project members for a specific project.

  ## Examples

      iex> list_project_members(project)
      [%ProjectMember{}, ...]
  """
  def list_project_members(project, filters \\ %{}) do
    OrangeCms.Projects.ListProjectMembersUsecase.call(project.id, filters)
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

      iex> add_project_member(project, %{field: value})
      {:ok, %ProjectMember{}}

      iex> add_project_member(project, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def add_project_member(project, attrs) do
    OrangeCms.Projects.AddUserToProjectUsecase.call(project, attrs)
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
    OrangeCms.Projects.UpdateProjectMemberUsecase.call(project_member, attrs)
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
    OrangeCms.Projects.RemoveProjectMemberUsecase.call(project_member)
  end
end
