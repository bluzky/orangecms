defmodule OrangeCms.Projects.ProjectUser do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  postgres do
    table("project_users")
    repo(OrangeCms.Repo)
  end

  attributes do
    uuid_primary_key(:id)
  end

  relationships do
    belongs_to :project, OrangeCms.Projects.Project,
      attribute_type: :string,
      allow_nil?: false,
      attribute_writable?: true

    belongs_to :user, OrangeCms.Accounts.User,
      allow_nil?: false,
      api: OrangeCms.Accounts,
      attribute_writable?: true
  end

  identities do
    identity :unique_project_user, [:project_id, :user_id]
  end

  code_interface do
    define_for(OrangeCms.Projects)
    define(:create, action: :create)
    define(:update, action: :update)
    define(:delete, action: :destroy)
    define(:get, args: [:id], action: :by_id)
  end

  actions do
    defaults [:read, :create, :update, :destroy]

    read :by_id do
      argument(:id, :string, allow_nil?: false)
      get?(true)
      filter(expr(id == ^arg(:id)))
    end
  end
end
