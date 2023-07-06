defmodule OrangeCms.Repo.Migrations.AddContentTables do
  use Ecto.Migration

  def change do
    create table(:content_types, primary_key: false) do
      add :id, :uuid, null: false, primary_key: true
      add :name, :text, null: false
      add :key, :text, null: false
      add :anchor_field, :text, null: false
      add :frontmatter_schema, :map, null: false, default: %{}
      add :image_settings, :map, null: false, default: %{}
      add :github_config, :map, null: false, default: %{}


      add :project_id, references(:projects, type: :uuid, on_delete: :delete_all), null: false
      timestamps(default: fragment("now()"))
    end

    create unique_index(:content_types, [:project_id, :key])


    create table(:content_entries, primary_key: false) do
      add :id, :uuid, null: false, primary_key: true
      add :title, :text, null: false
      add :slug, :text
      add :frontmatter, :map, null: false, default: %{}
add :json_body, :map
      add :body, :text
      add :integration_info, :map, default: %{}

      add :project_id, references(:projects, type: :uuid, on_delete: :delete_all), null: false
      add :content_type_id, references(:content_types, type: :uuid, on_delete: :delete_all), null: false
      timestamps(default: fragment("now()"))
    end

    create index(:content_entries, [:content_type_id, :project_id])
  end
end
