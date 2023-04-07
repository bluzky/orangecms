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

  calculations do
    calculate :full_name, :string, expr(first_name <> " " <> last_name)
  end

  code_interface do
    define_for(OrangeCms.Accounts)
    define(:create, action: :create)
    define(:read_all, action: :read_all)
    define(:update, action: :update)
    define(:delete, action: :destroy)
    define(:get, args: [:id], action: :by_id)
    define(:get_by_email, args: [:email], action: :by_email)
  end

  actions do
    defaults([:read, :update, :destroy])

    read :read_all do
      prepare(build(sort: [first_name: :asc]))
    end

    read :by_id do
      argument(:id, :uuid, allow_nil?: false)
      get?(true)
      filter(expr(id == ^arg(:id)))
    end

    read :by_email do
      argument(:key, :string, allow_nil?: false)
      get?(true)
      filter(expr(key == ^arg(:email)))
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
