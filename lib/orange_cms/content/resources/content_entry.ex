defmodule OrangeCms.Content.ContentEntry do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [
      AshGraphql.Resource
    ]

  postgres do
    table("content_entries")
    repo(OrangeCms.Repo)
  end

  code_interface do
    define_for(OrangeCms.Content)
    define(:create, action: :create)
    define(:read_all, action: :read)
    define(:update, action: :update)
    define(:delete, action: :destroy)
    define(:get, args: [:id], action: :by_id)
    define(:get_by_type, args: [:content_type_id], action: :by_type)
  end

  actions do
    defaults([:create, :read, :update, :destroy])

    read :by_id do
      argument(:id, :uuid, allow_nil?: false)
      get?(true)
      filter(expr(id == ^arg(:id)))
    end

    read :by_type do
      argument(:content_type_id, :uuid)
      argument(:type, :string)
      prepare(build(sort: [created_at: :desc]))
      filter(expr(content_type_id == ^arg(:content_type_id) or content_type.key == ^arg(:type)))
    end
  end

  attributes do
    uuid_primary_key(:id)

    attribute :title, :string do
      allow_nil?(false)
    end

    attribute :raw_body, :string do
      allow_nil?(false)
    end

    attribute :json_body, :map do
      default(%{})
    end

    attribute :frontmatter, :map do
      default(%{})
    end

    create_timestamp(:created_at)
    update_timestamp(:updated_at)
  end

  alias OrangeCms.Content.ContentType

  relationships do
    belongs_to :content_type, ContentType do
      allow_nil?(false)
      attribute_writable?(true)
    end
  end

  # graphql for list entry and get entry
  graphql do
    type(:content_entry)

    queries do
      get(:get_entry, :read)
      list(:list_entries, :by_type)
    end
  end
end
