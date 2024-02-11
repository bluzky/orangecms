defmodule OrangeCms.Content.ContentEntry do
  @moduledoc false
  use OrangeCms, :schema

  alias OrangeCms.Content.ContentEntry

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "content_entries" do
    field :slug, :string
    field :title, :string
    field :frontmatter, :map
    field :json_body, :map
    field :body, :string, default: ""

    embeds_one :integration_info, OrangeCms.Content.GithubInfo, on_replace: :update

    belongs_to :content_type, OrangeCms.Content.ContentType
    belongs_to :project, OrangeCms.Projects.Project

    timestamps()
  end

  @doc false
  def changeset(content_entry, attrs) do
    content_entry
    |> cast(attrs, [
      :title,
      :slug,
      :body,
      :json_body,
      :frontmatter,
      :content_type_id,
      :project_id
    ])
    |> cast_embed(:integration_info)
    |> validate_required([:title, :content_type_id, :project_id])
  end

  @filterable_fields [:title, :slug, :body, :content_type_id, :project_id]
  @doc """
  Base query
  """
  def query do
    ContentEntry
  end

  @doc """
  compose query
  """
  def add_filter(query, filters) when is_map(filters) do
    filters
    |> Enum.filter(fn {k, _v} -> k in @filterable_fields end)
    |> Enum.reduce(query, fn {k, v}, query ->
      add_filter(query, k, v)
    end)
  end

  def add_filter(query, field, value) when field in @filterable_fields do
    filter_by(query, field, value)
  end

  def filter_by(query, :title, value) do
    if value not in [nil, ""] do
      where(query, [c], ilike(c.title, ^"%#{value}%"))
    else
      query
    end
  end

  def filter_by(query, field, value) do
    Filtery.filter(query, field, value)
  end
end

defmodule OrangeCms.Content.GithubInfo do
  @moduledoc false
  use OrangeCms, :schema

  @primary_key false
  embedded_schema do
    field :name, :string
    field :relative_path, :string
    field :full_path, :string
    field :sha, :string
  end

  def changeset(github_info, attrs) do
    cast(github_info, attrs, [:name, :relative_path, :full_path, :sha])
  end
end
