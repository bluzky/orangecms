defmodule OrangeCms.Content.ContentEntry do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "content_entries"
    repo OrangeCms.Repo
  end

  code_interface do
    define_for OrangeCms.Content
    define :create, action: :create
    define :list, action: :read
    define :update, action: :update
    define :destroy, action: :destroy
    define :get, args: [:id], action: :by_id
  end

  actions do
    defaults [:create, :read, :update, :destroy]

    read :by_id do
      argument :id, :uuid, allow_nil?: false
      get? true
      filter expr(id == ^arg(:id))
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :title, :string do
      allow_nil? false
    end

    attribute :raw_body, :string do
      allow_nil? false
    end

    attribute :json_body, :map do
      default %{}
    end

    attribute :frontmatter, :map do
      default %{}
    end
  end

  alias OrangeCms.Content.ContentType

  relationships do
    belongs_to :content_type, ContentType
  end
end
