defmodule OrangeCms.Content.ContentEntry do
  @moduledoc false
  use OrangeCms, :schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "content_entries" do
    field :slug, :string
    field :title, :string
    field :frontmatter, :map
    field :json_body, :map
    field :raw_body, :string, default: ""

    embeds_one :integration_info, OrangeCms.Content.GithubInfo, on_replace: :update

    belongs_to :content_type, OrangeCms.Content.ContentType
    belongs_to :project, OrangeCms.Project, type: :binary

    timestamps()
  end

  @doc false
  def changeset(content_entry, attrs) do
    content_entry
    |> cast(attrs, [
      :title,
      :slug,
      :raw_body,
      :json_body,
      :frontmatter,
      :content_type_id,
      :project_id
    ])
    |> cast_embed(:integration_info)
    |> validate_required([:title, :content_type_id, :project_id])
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
