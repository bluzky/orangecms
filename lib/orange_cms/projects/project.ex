defmodule OrangeCms.Projects.Project do
  @moduledoc false
  use OrangeCms, :schema

  schema "projects" do
    field(:name, :string)
    field(:code, :string, autogenerate: {OrangeCms.Shared.Nanoid, :generate, []})
    field(:type, Ecto.Enum, values: [:github, :headless_cms], default: :github)
    field(:setup_completed, :boolean, default: false)
    field(:github_config, :map, default: %{})
    belongs_to(:owner, OrangeCms.Account.User)
    has_many(:project_users, OrangeCms.Projects.ProjectUser)

    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :type, :github_config, :setup_completed, :owner_id])
    |> validate_required([:name, :type, :owner_id])
  end
end
