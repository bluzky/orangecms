defmodule OrangeCms.Accounts.User do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication]

  attributes do
    uuid_primary_key(:id)
    attribute(:first_name, :string)
    attribute(:last_name, :string)
    attribute(:email, :ci_string, allow_nil?: false)
    attribute(:hashed_password, :string, allow_nil?: false, sensitive?: true)
    attribute(:avatar, :string)
    attribute(:is_active, :boolean, default: true)
    attribute(:is_blocked, :boolean, default: false)
    attribute(:is_admin, :boolean, default: false, private?: true)
  end

  relationships do
    many_to_many :projects, OrangeCms.Projects.Project do
      through OrangeCms.Projects.ProjectUser
      source_attribute_on_join_resource :user_id
      destination_attribute_on_join_resource :project_id
      api OrangeCms.Projects
    end
  end

  calculations do
    calculate :full_name, :string, expr(first_name <> " " <> last_name)
  end

  code_interface do
    define_for(OrangeCms.Accounts)
    define(:create, action: :create)
    define(:read, action: :read)
    define(:update, action: :update)
    define(:delete, action: :destroy)
    define(:get, args: [:id], action: :by_id)
    define(:get_by_email, args: [:email], action: :by_email)
    define(:search, args: [:q], action: :search)
  end

  actions do
    defaults([:read, :update, :destroy])

    read :by_id do
      argument(:id, :uuid, allow_nil?: false)
      get?(true)
      filter(expr(id == ^arg(:id)))
    end

    read :by_email do
      argument(:email, :string, allow_nil?: false)
      get?(true)
      filter(expr(email == ^arg(:email)))
    end

    read :search do
      argument(:q, :string, allow_nil?: false)
      pagination offset?: true, keyset?: true, required?: false
      filter(expr(contains(email, ^arg(:q))))
    end

    create :create do
      allow_nil_input [:hashed_password]
      reject [:hashed_password]

      argument :password, :string do
        allow_nil? false
      end
    end
  end

  changes do
    change set_context(%{strategy_name: :password})
    change AshAuthentication.Strategy.Password.HashPasswordChange
  end

  authentication do
    api(OrangeCms.Accounts)

    strategies do
      password :password do
        identity_field(:email)
        hashed_password_field(:hashed_password)
      end
    end
  end

  postgres do
    table("users")
    repo(OrangeCms.Repo)
  end

  identities do
    identity(:unique_email, [:email])
  end
end
