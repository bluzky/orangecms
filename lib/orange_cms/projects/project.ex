defmodule OrangeCms.Projects.Project do
  @moduledoc false
  use OrangeCms, :schema

  schema "projects" do
    field(:name, :string)
    field(:code, :string, autogenerate: {OrangeCms.Shared.Nanoid, :generate, []})
    field(:type, Ecto.Enum, values: [:github, :headless_cms], default: :github)
    field(:setup_completed, :boolean, default: false)
    field(:github_config, :map, default: %{})
    belongs_to(:owner, OrangeCms.Accounts.User)
    has_many(:project_members, OrangeCms.Projects.ProjectMember)

    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :type, :github_config, :setup_completed, :owner_id])
    |> validate_required([:name, :type, :owner_id])
  end

  def change_members(changeset) do
    changeset
    |> cast_assoc(:project_members,
      with: &OrangeCms.Projects.ProjectMember.assoc_changeset/2,
      required: true
    )
  end
end
