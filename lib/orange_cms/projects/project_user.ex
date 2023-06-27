defmodule OrangeCms.Projects.ProjectUser do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "project_users" do
    field :is_owner, :boolean, default: false
    field :role, :string
    belongs_to :project, OrangeCms.Projects.Project, type: :string
    belongs_to :user, OrangeCms.Accounts.User
  end

  @doc false
  def changeset(project_user, attrs) do
    project_user
    |> cast(attrs, [:role, :is_owner, :project_id, :user_id])
    |> validate_required([:role, :project_id, :user_id])
  end
end
