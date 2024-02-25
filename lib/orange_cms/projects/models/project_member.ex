defmodule OrangeCms.Projects.ProjectMember do
  @moduledoc false
  use OrangeCms, :schema

  schema "project_members" do
    field(:is_owner, :boolean, default: false)
    field(:role, Ecto.Enum, values: [:admin, :editor], default: :editor)
    belongs_to(:project, OrangeCms.Projects.Project)
    belongs_to(:user, OrangeCms.Accounts.User)
  end

  @doc false
  def changeset(project_member, attrs) do
    project_member
    |> cast(attrs, [:role, :is_owner, :project_id, :user_id])
    |> validate_required([:role, :project_id, :user_id])
  end

  @doc false
  def assoc_changeset(project_member, attrs) do
    project_member
    |> cast(attrs, [:role, :is_owner, :project_id, :user_id])
    |> validate_required([:role, :user_id])
  end
end
