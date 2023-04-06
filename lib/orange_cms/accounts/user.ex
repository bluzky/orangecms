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

  postgres do
    table("users")
    repo(OrangeCms.Repo)
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

  identities do
    identity(:unique_email, [:email])
  end
end
