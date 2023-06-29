defmodule OrangeCms.Content do
  @moduledoc false
  use OrangeCms, :context

  alias OrangeCms.Content.ContentEntry
  alias OrangeCms.Content.ContentType

  @doc """
  Returns the list of content_types.

  ## Examples

      iex> list_content_types()
      [%ContentType{}, ...]

  """
  def list_content_types(project_id) do
    ContentType
    |> Filtery.filter(:project_id, project_id)
    |> Repo.all()
  end

  @doc """
  Gets a single content_type.

  Raises `Ecto.NoResultsError` if the Content type does not exist.

  ## Examples

      iex> get_content_type!(123)
      %ContentType{}

      iex> get_content_type!(456)
      ** (Ecto.NoResultsError)

  """
  def get_content_type!(id), do: Repo.get!(ContentType, id)

  def find_content_type(project_id, filter) do
    ContentType
    |> Filtery.filter(:project_id, project_id)
    |> Filtery.apply(filter)
    |> Repo.one()
  end

  @doc """
  Creates a content_type.

  ## Examples

      iex> create_content_type(%{field: value})
      {:ok, %ContentType{}}

      iex> create_content_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_content_type(attrs \\ %{}) do
    %ContentType{}
    |> ContentType.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a content_type.

  ## Examples

      iex> update_content_type(content_type, %{field: new_value})
      {:ok, %ContentType{}}

      iex> update_content_type(content_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_content_type(%ContentType{} = content_type, attrs) do
    content_type
    |> ContentType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a content_type.

  ## Examples

      iex> delete_content_type(content_type)
      {:ok, %ContentType{}}

      iex> delete_content_type(content_type)
      {:error, %Ecto.Changeset{}}

  """
  def delete_content_type(%ContentType{} = content_type) do
    Repo.delete(content_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking content_type changes.

  ## Examples

      iex> change_content_type(content_type)
      %Ecto.Changeset{data: %ContentType{}}

  """
  def change_content_type(%ContentType{} = content_type, attrs \\ %{}) do
    ContentType.changeset(content_type, attrs)
  end

  @doc """
  Returns the list of content_entries.

  ## Examples

      iex> list_content_entries()
      [%ContentEntry{}, ...]

  """
  def list_content_entries(project_id, filters) do
    ContentEntry
    |> Filtery.filter(:project_id, project_id)
    |> Filtery.apply(filters)
    |> Repo.all()
  end

  @doc """
  Gets a single content_entry.

  Raises `Ecto.NoResultsError` if the Content entry does not exist.

  ## Examples

      iex> get_content_entry!(123)
      %ContentEntry{}

      iex> get_content_entry!(456)
      ** (Ecto.NoResultsError)

  """
  def get_content_entry!(id), do: Repo.get!(ContentEntry, id)

  @doc """
  Creates a content_entry.

  ## Examples

      iex> create_content_entry(%{field: value})
      {:ok, %ContentEntry{}}

      iex> create_content_entry(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_content_entry(attrs \\ %{}) do
    %ContentEntry{}
    |> ContentEntry.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a content_entry.

  ## Examples

      iex> update_content_entry(content_entry, %{field: new_value})
      {:ok, %ContentEntry{}}

      iex> update_content_entry(content_entry, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_content_entry(%ContentEntry{} = content_entry, attrs) do
    content_entry
    |> ContentEntry.changeset(attrs)
    |> OrangeCms.Content.CastFrontmatter.change(content_entry.content_type)
    |> Repo.update()
  end

  @doc """
  Deletes a content_entry.

  ## Examples

      iex> delete_content_entry(content_entry)
      {:ok, %ContentEntry{}}

      iex> delete_content_entry(content_entry)
      {:error, %Ecto.Changeset{}}

  """
  def delete_content_entry(%ContentEntry{} = content_entry) do
    Repo.delete(content_entry)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking content_entry changes.

  ## Examples

      iex> change_content_entry(content_entry)
      %Ecto.Changeset{data: %ContentEntry{}}

  """
  def change_content_entry(%ContentEntry{} = content_entry, attrs \\ %{}) do
    content_entry
    |> ContentEntry.changeset(attrs)
    |> OrangeCms.Content.CastFrontmatter.change(content_entry.content_type)
  end
end
