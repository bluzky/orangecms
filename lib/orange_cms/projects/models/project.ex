defmodule OrangeCms.Projects.Project do
  @moduledoc false
  use OrangeCms, :schema

  schema "projects" do
    field(:name, :string)
    field(:code, :string, autogenerate: {OrangeCms.Shared.Nanoid, :generate, []})
    field(:type, Ecto.Enum, values: [:github, :headless_cms], default: :github)
    field(:setup_completed, :boolean, default: false)
    embeds_one(:github_config, OrangeCms.Projects.Project.GithubConfig, on_replace: :update)
    belongs_to(:owner, OrangeCms.Accounts.User)
    has_many(:project_members, OrangeCms.Projects.ProjectMember)

    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :type, :setup_completed, :owner_id])
    |> cast_embed(:github_config, with: &OrangeCms.Projects.Project.GithubConfig.changeset/2)
    |> validate_required([:name, :type, :owner_id])
  end

  def change_members(changeset) do
    cast_assoc(changeset, :project_members, with: &OrangeCms.Projects.ProjectMember.assoc_changeset/2, required: true)
  end
end

defmodule OrangeCms.Projects.Project.GithubConfig do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field(:repo_name, :string)
    field(:repo_owner, :string)
    field(:repo_branch, :string)
    field(:access_token, :string)
  end

  def changeset(model, attrs \\ %{}) do
    cast(model, attrs, [:repo_name, :repo_owner, :repo_branch, :access_token])
  end
end
