defmodule OrangeCms.Projects.Project do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table("projects")
    repo(OrangeCms.Repo)
  end

  code_interface do
    define_for(OrangeCms.Projects)
    define(:read, action: :read)
    define(:create, action: :create)
    define(:update, action: :update)
    define(:delete, action: :destroy)
    define(:get, args: [:id], action: :by_id)
    define :list_my_projects, action: :list_my_projects
  end

  actions do
    defaults([:read, :update, :destroy])

    read :by_id do
      argument(:id, :string, allow_nil?: false)
      get?(true)
      filter(expr(id == ^arg(:id)))
    end

    read :list_my_projects do
      filter(expr(^actor(:id) == owner_id or users.id == ^actor(:id)))
    end

    create :create do
      change relate_actor(:owner)
    end
  end

  attributes do
    attribute :id, :string do
      allow_nil?(false)
      writable?(false)
      default(&OrangeCms.Shared.Nanoid.generate/0)
      primary_key?(true)
      generated?(true)
    end

    attribute :name, :string do
      allow_nil?(false)
    end

    attribute(:image, :string)

    attribute :type, :atom do
      constraints(one_of: OrangeCms.Projects.ProjectType.values())
      default(:headless_cms)
    end

    attribute :github_config, :map do
      default(%{})
    end

    attribute(:set_up_completed, :boolean, default: false)

    create_timestamp(:created_at)
    update_timestamp(:updated_at)
  end

  relationships do
    has_many :project_users, OrangeCms.Projects.ProjectUser

    many_to_many :users, OrangeCms.Accounts.User do
      through OrangeCms.Projects.ProjectUser
      source_attribute_on_join_resource :project_id
      destination_attribute_on_join_resource :user_id
      api OrangeCms.Accounts
    end

    belongs_to :owner, OrangeCms.Accounts.User do
      api OrangeCms.Accounts
    end
  end

  policies do
    policy accessing_from(OrangeCms.Accounts.User, :projects) do
      authorize_if always()
    end

    policy action(:create) do
      authorize_if actor_present()
    end

    policy action(:list_my_projects) do
      authorize_if actor_present()
    end

    policy action(:by_id) do
      authorize_if expr(^actor(:id) == owner_id or users.id == ^actor(:id))
    end
  end
end
