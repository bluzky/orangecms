defmodule OrangeCms.Content.ContentType do
  use OrangeCms, :schema

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "content_types" do
    field :name, :string
    field :key, :string
    field :anchor_field, :string
    embeds_many :field_defs, OrangeCms.Content.FieldDef
    field :github_config, :map, default: %{}
    embeds_one :image_settings, OrangeCms.Content.ImageUploadSettings

    belongs_to :project, OrangeCms.Projects.Project, type: :binary
    timestamps()
  end

  @doc false
  def changeset(content_type, attrs) do
    content_type
    |> cast(attrs, [:name, :key, :anchor_field, :github_config])
    |> cast_embed(:image_settings, default: %{})
    |> validate_required([
      :name,
      :key,
      :anchor_field,
      :github_config
    ])
  end
end

defmodule OrangeCms.Content.ImageUploadSettings do
  use OrangeCms, :schema

  embedded_schema do
    field :upload_dir, :string
    field :serve_at, :string, default: "/"
    field :use_raw_link, :boolean, default: false
  end

  def changeset(model, attrs) do
    model
    |> cast(attrs, [:upload_dir, :serve_at, :use_raw_link])
  end
end

defmodule OrangeCms.Content.GithubConfig do
  use OrangeCms, :schema

  embedded_schema do
    field :name, :string
    field :relative_path, :string
    field :full_path, :string
    field :sha, :string
  end
end

defmodule OrangeCms.Content.FieldDef do
  use OrangeCms, :schema

  embedded_schema do
    field :name, :string
    field :key, :string
    field :type, :string, default: "string"
    field :default_value, :string
    field :option_str, :string, default: ""
    field :is_required, :boolean, default: false
  end

  def changeset(model, attrs) do
    model
    |> cast(attrs, [:name, :key, :type, :default_value, :option_str, :is_required])

    # |> validate_inclustion
  end
end
