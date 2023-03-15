defmodule OrangeCms.Content.ContentType do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  # The Postgres keyword is specific to the AshPostgres module.
  postgres do
    # Tells Postgres what to call the table
    table("content_types")
    # Tells Ash how to interface with the Postgres table
    repo(OrangeCms.Repo)

    references do
      reference(:project,
        on_delete: :delete,
        on_update: :update,
        name: "content_types_project_id_fkey"
      )
    end
  end

  # Defines convenience methods for
  # interacting with the resource programmatically.
  code_interface do
    define_for(OrangeCms.Content)
    define(:create, action: :create)
    define(:read_all, action: :read_all)
    define(:update, action: :update)
    define(:delete, action: :destroy)
    define(:get, args: [:id], action: :by_id)
    define(:get_by_key, args: [:key], action: :by_key)
  end

  actions do
    defaults([:create, :read, :update, :destroy])

    read :read_all do
      prepare(build(sort: [created_at: :desc]))
    end

    read :by_id do
      argument(:id, :uuid, allow_nil?: false)
      get?(true)
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

  multitenancy do
    strategy(:attribute)
    attribute(:project_id)
  end

  alias OrangeCms.Projects.Project

  relationships do
    belongs_to :project, Project do
      attribute_type(:string)
      allow_nil?(false)
      attribute_writable?(true)
      api(OrangeCms.Projects)
    end
  end
end
