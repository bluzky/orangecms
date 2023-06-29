defmodule OrangeCms.Repo.Migrations.AddProjectUserRole do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:project_users) do
      add :role, :text, default: "editor"
      add :is_owner, :boolean, default: false
    end
  end

  def down do
    alter table(:project_users) do
      remove :is_owner
      remove :role
    end
  end
end
