defmodule OrangeCms.Projects do
  use OrangeCms, :context

  alias OrangeCms.Projects.Project

  @doc """
  Returns the list of projects.

  ## Examples

      iex> list_projects()
      [%Project{}, ...]

  """
  def list_my_projects do
    # TODO: update query for my project
    Repo.all(Project)
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
    # TODO: find proper way to get actor
    actor = OrangeCms.get_actor()

    %Project{owner_id: actor.id}
    |> Project.changeset(attrs)
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

  alias OrangeCms.Projects.ProjectUser

  @doc """
  Returns the list of project_users.

  ## Examples

      iex> list_project_users()
      [%ProjectUser{}, ...]

  """
  def list_project_users(project) do
    ProjectUser
    |> Filtery.filter(:project_id, project.id)
    |> Repo.all()
    |> Repo.preload(:user)
  end

  @doc """
  Gets a single project_user.

  Raises `Ecto.NoResultsError` if the Project user does not exist.

  ## Examples

      iex> get_project_user!(123)
      %ProjectUser{}

      iex> get_project_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_project_user!(id), do: Repo.get!(ProjectUser, id)

  @doc """
  Creates a project_user.

  ## Examples

      iex> create_project_user(%{field: value})
      {:ok, %ProjectUser{}}

      iex> create_project_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project_user(attrs \\ %{}) do
    %ProjectUser{}
    |> ProjectUser.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a project_user.

  ## Examples

      iex> update_project_user(project_user, %{field: new_value})
      {:ok, %ProjectUser{}}

      iex> update_project_user(project_user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_project_user(%ProjectUser{} = project_user, attrs) do
    project_user
    |> ProjectUser.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a project_user.

  ## Examples

      iex> delete_project_user(project_user)
      {:ok, %ProjectUser{}}

      iex> delete_project_user(project_user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_project_user(%ProjectUser{} = project_user) do
    Repo.delete(project_user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project_user changes.

  ## Examples

      iex> change_project_user(project_user)
      %Ecto.Changeset{data: %ProjectUser{}}

  """
  def change_project_user(%ProjectUser{} = project_user, attrs \\ %{}) do
    ProjectUser.changeset(project_user, attrs)
  end
end
