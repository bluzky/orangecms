defmodule OrangeCms.Repo.Migrations.AddProject do
  use Ecto.Migration

  def change do
    create table(:projects, primary_key: false) do
      add :id, :uuid, null: false, primary_key: true
      add :name, :text, null: false
      add :code, :text, null: false
      add :type, :text, null: false
      add :setup_completed, :boolean, null: false, default: false
      add :github_config, :map, default: %{}
      add :owner_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
      timestamps(default: fragment("now()"))
    end

    create unique_index(:projects, [:code])
  end
end
