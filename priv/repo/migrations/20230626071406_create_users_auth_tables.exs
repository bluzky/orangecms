defmodule OrangeCms.Repo.Migrations.CreateUsersAuthTables do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:users, primary_key: false) do
      add :id, :uuid, null: false, primary_key: true
      add :email, :citext, null: false
      add :hashed_password, :string, null: false
      add :confirmed_at, :naive_datetime

      add :first_name, :text
      add :last_name, :text
      add :is_blocked, :boolean, default: false
      add :is_admin, :boolean, default: false
      timestamps(default: fragment("NOW()"))
    end

    create unique_index(:users, [:email])

    create table(:users_tokens, primary_key: false) do
      add :id, :uuid, null: false, primary_key: true
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create index(:users_tokens, [:user_id])
    create unique_index(:users_tokens, [:context, :token])
  end
end
