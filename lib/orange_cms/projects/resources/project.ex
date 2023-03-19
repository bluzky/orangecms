defmodule OrangeCms.Projects.Project do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  postgres do
    table("projects")
    repo(OrangeCms.Repo)
  end

  code_interface do
    define_for(OrangeCms.Projects)
    define(:create, action: :create)
    define(:read_all, action: :read)
    define(:update, action: :update)
    define(:delete, action: :destroy)
    define(:get, args: [:id], action: :by_id)
  end

  actions do
    defaults([:create, :read, :update, :destroy])

    read :by_id do
      argument(:id, :string, allow_nil?: false)
      get?(true)
      filter(expr(id == ^arg(:id)))
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
end
