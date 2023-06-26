defmodule OrangeCms.Projects.ProjectUser do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table("project_users")
    repo(OrangeCms.Repo)
  end

  attributes do
    uuid_primary_key(:id)

    attribute :role, :atom do
      constraints(one_of: OrangeCms.Projects.MemberRole.values())
      default(:editor)
    end

    attribute :is_owner, :boolean, default: false, private?: true
  end

  relationships do
    belongs_to :project, OrangeCms.Projects.Project,
      attribute_type: :string,
      allow_nil?: false,
      attribute_writable?: true

    belongs_to :user, OrangeCms.Accounts.OUser,
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
    define(:get_membership, args: [:project_id, :user_id], action: :get_membership)
  end

  actions do
    defaults [:read, :create, :update, :destroy]

    read :by_id do
      argument(:id, :string, allow_nil?: false)
      get?(true)
      filter(expr(id == ^arg(:id)))
    end

    read :get_membership do
      argument(:project_id, :string, allow_nil?: false)
      argument(:user_id, :uuid, allow_nil?: false)
      get?(true)
      filter(expr(project_id == ^arg(:project_id) and user_id == ^arg(:user_id)))
    end

    create :create_owner do
      change {OrangeCms.Projects.Change.ForceChange, [is_owner: true]}
    end
  end

  policies do
    bypass action(:get_membership) do
      authorize_if actor_present()
    end

    policy action(:destroy) do
      forbid_if(expr(is_admin == true))
    end

    policy always() do
      authorize_if actor_attribute_equals(:role, :admin)
    end
  end
end
