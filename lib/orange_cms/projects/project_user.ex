defmodule OrangeCms.Projects.ProjectUser do
  use Ecto.Schema
  import Ecto.Changeset

  schema "project_users" do
    field :is_owner, :boolean, default: false
    field :role, :string
    belongs_to :project, OrangeCms.Projects.Project
    belongs_to :user, OrangeCms.Account.User

    timestamps()
  end

  @doc false
  def changeset(project_user, attrs) do
    project_user
    |> cast(attrs, [:role, :is_owner, :project_id, :user_id])
    |> validate_required([:role, :project_id, :user_id])
  end
end
