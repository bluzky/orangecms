defmodule OrangeCms.Content.FieldDef do
  use Ash.Resource,
    data_layer: :embedded

  attributes do
    attribute :name, :string do
      allow_nil? false
    end

    attribute :key, :string do
      allow_nil? false
    end

    attribute :type, :string do
      default "string"
    end

    attribute :default_value, :string

    attribute :options, {:array, :string} do
      default []
    end

    attribute :is_required, :boolean do
      default false
    end
  end
end
