defmodule OrangeCms.Content.ContentType do
  @moduledoc false
  use OrangeCms, :schema

  schema "content_types" do
    field(:name, :string)
    field(:key, :string)
    field(:anchor_field, :string)
    embeds_many(:frontmatter_schema, OrangeCms.Content.FieldDef, on_replace: :delete)
    embeds_one(:github_config, OrangeCms.Content.GithubConfig, on_replace: :update)

    belongs_to(:project, OrangeCms.Projects.Project)
    timestamps()
  end

  @doc false
  def changeset(content_type, attrs) do
    content_type
    |> cast(attrs, [:name, :key, :anchor_field, :project_id])
    |> cast_embed(:github_config, default: %{})
    |> cast_embed(:frontmatter_schema, default: [])
    |> generate_key()
    |> validate_required([
      :name,
      :project_id
    ])
    |> unsafe_validate_unique([:project_id, :key], OrangeCms.Repo, error_key: :key)
    |> unique_constraint([:project_id, :key])
  end

  # build key from name
  defp generate_key(changeset) do
    with {:ok, name} <- fetch_change(changeset, :name),
         {_, nil} <- fetch_field(changeset, :key) do
      put_change(changeset, :key, name |> String.downcase() |> String.replace(" ", "_"))
    else
      _err ->
        changeset
    end
  end
end

defmodule OrangeCms.Content.GithubConfig do
  @moduledoc false
  use OrangeCms, :schema

  embedded_schema do
    field(:content_dir, :string)
    field(:upload_dir, :string)
    field(:serve_at, :string, default: "/")
    field(:use_raw_link, :boolean, default: false)
  end

  def changeset(model, attrs) do
    cast(model, attrs, [:content_dir, :upload_dir, :serve_at, :use_raw_link])
  end
end

defmodule OrangeCms.Content.FieldDef do
  @moduledoc false
  use OrangeCms, :schema

  @primary_key false
  embedded_schema do
    field(:name, :string)
    field(:key, :string)

    field(:type, Ecto.Enum,
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
    )

    field(:default_value, :string)
    field(:options_str, :string, default: "")
    field(:options, {:array, :string}, default: [], virtual: true)
    field(:is_required, :boolean, default: false)
  end

  def changeset(model, attrs) do
    model
    |> cast(attrs, [:name, :key, :type, :default_value, :options_str, :is_required])
    |> validate_required([:name, :key, :type])
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
