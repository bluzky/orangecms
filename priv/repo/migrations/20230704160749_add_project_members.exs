defmodule OrangeCms.Repo.Migrations.AddProjectMembers do
  use Ecto.Migration

  def change do
    create table(:project_members, primary_key: false) do
      add :id, :uuid, null: false, primary_key: true
      add :is_owner, :boolean, null: false, default: false
      add :role, :text, null: false
      add :project_id, references(:projects, type: :uuid, on_delete: :delete_all), null: false
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
      timestamps(default: fragment("now()"))
    end

    create unique_index(:project_members, [:project_id, :user_id])

  end
end
