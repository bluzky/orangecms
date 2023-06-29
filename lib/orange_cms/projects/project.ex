defmodule OrangeCms.Projects.Project do
  @moduledoc false
  use OrangeCms, :schema

  @primary_key {:id, :string, autogenerate: {OrangeCms.Shared.Nanoid, :generate, []}}
  schema "projects" do
    field :name, :string
    field :type, Ecto.Enum, values: [:github, :headless_cms], default: :github
    field :image, :string
    field :setup_completed, :boolean, default: false
    field :github_config, :map, default: %{}
    belongs_to :owner, OrangeCms.Account.User
    has_many :project_users, OrangeCms.Projects.ProjectUser

    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :image, :type, :github_config, :setup_completed, :owner_id])
    |> validate_required([:name, :type, :owner_id])
  end
end
