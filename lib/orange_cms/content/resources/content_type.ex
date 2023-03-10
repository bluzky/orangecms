defmodule OrangeCms.Content.ContentType do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  # The Postgres keyword is specific to the AshPostgres module.
  postgres do
    # Tells Postgres what to call the table
    table("content_types")
    # Tells Ash how to interface with the Postgres table
    repo(OrangeCms.Repo)
  end

  # Defines convenience methods for
  # interacting with the resource programmatically.
  code_interface do
    define_for(OrangeCms.Content)
    define(:create, action: :create)
    define(:read_all, action: :read)
    define(:update, action: :update)
    define(:delete, action: :destroy)
    define(:get, args: [:id], action: :by_id)
    define(:get_by_key, args: [:key], action: :by_key)
  end

  actions do
    # Exposes default built in actions to manage the resource
    defaults([:create, :read, :update, :destroy])

    # Defines custom read action which fetches post by id.
    read :by_id do
      # This action has one argument :id of type :uuid
      argument(:id, :uuid, allow_nil?: false)
      # Tells us we expect this action to return a single result
      get?(true)
      # Filters the `:id` given in the argument
      # against the `id` of each element in the resource
      filter(expr(id == ^arg(:id)))
    end

    read :by_key do
      argument(:key, :string, allow_nil?: false)
      get?(true)
      filter(expr(key == ^arg(:key)))
    end
  end

  alias OrangeCms.Content.FieldDef

  attributes do
    uuid_primary_key(:id)

    attribute :name, :string do
      allow_nil?(false)
    end

    attribute :key, :string do
      allow_nil?(false)
    end

    attribute :image_settings, :map do
      allow_nil?(true)
    end

    attribute :field_defs, {:array, FieldDef} do
      default([])
    end

    attribute :anchor_field, :string do
      allow_nil?(true)
    end

    create_timestamp(:created_at)
    update_timestamp(:updated_at)
  end
end
