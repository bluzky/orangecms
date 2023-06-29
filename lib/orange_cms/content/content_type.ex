defmodule OrangeCms.Content.ContentType do
  @moduledoc false
  use OrangeCms, :schema

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "content_types" do
    field :name, :string
    field :key, :string
    field :anchor_field, :string
    embeds_many :field_defs, OrangeCms.Content.FieldDef, on_replace: :delete
    field :github_config, :map, default: %{}
    embeds_one :image_settings, OrangeCms.Content.ImageUploadSettings, on_replace: :update

    belongs_to :project, OrangeCms.Projects.Project, type: :binary
    timestamps()
  end

  @doc false
  def changeset(content_type, attrs) do
    content_type
    |> cast(attrs, [:name, :key, :anchor_field, :github_config, :project_id])
    |> cast_embed(:image_settings, default: %{})
    |> cast_embed(:field_defs, default: [])
    |> validate_required([
      :name,
      :key,
      :project_id
    ])
  end
end

defmodule OrangeCms.Content.ImageUploadSettings do
  @moduledoc false
  use OrangeCms, :schema

  embedded_schema do
    field :upload_dir, :string
    field :serve_at, :string, default: "/"
    field :use_raw_link, :boolean, default: false
  end

  def changeset(model, attrs) do
    cast(model, attrs, [:upload_dir, :serve_at, :use_raw_link])
  end
end

defmodule OrangeCms.Content.FieldDef do
  @moduledoc false
  use OrangeCms, :schema

  @primary_key false
  embedded_schema do
    field :name, :string
    field :key, :string

    field :type, Ecto.Enum,
      values: [
        :string,
        :text,
        :number,
        :boolean,
        :datetime,
        :date,
        :select,
        :array,
        :checkbox,
        :upload
      ],
      default: :string

    field :default_value, :string
    field :options_str, :string, default: ""
    field :options, {:array, :string}, default: [], virtual: true
    field :is_required, :boolean, default: false
  end

  def changeset(model, attrs) do
    cast(model, attrs, [:name, :key, :type, :default_value, :options_str, :is_required])
  end

  def load(record, :options) do
    options =
      record.options_str
      |> Kernel.||("")
      |> String.split(",")
      |> Enum.map(&String.trim/1)

    %{record | options: options}
  end

  def default_value(field) do
    case field do
      %{default_value: nil} ->
        nil

      %{type: :string} ->
        ## render template string with datetime 
        Calendar.strftime(DateTime.utc_now(), field.default_value)

      %{type: :date, default_value: "today()"} ->
        Date.utc_today()

      %{type: :datetime, default_value: "now()"} ->
        NaiveDateTime.utc_now()

      _ ->
        case cast_field(field, field.default_value) do
          {:ok, value} ->
            value

          _error ->
            nil
        end
    end
  end

  def cast_field(field, value) do
    Ecto.Type.cast(OrangeCms.Content.InputType.stored_type(field.type), value)
  end
end
