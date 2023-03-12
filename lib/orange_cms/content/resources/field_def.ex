defmodule OrangeCms.Content.FieldDef do
  use Ash.Resource,
    data_layer: :embedded

  attributes do
    attribute(:name, :string)

    attribute :key, :string do
      allow_nil?(false)
    end

    attribute :type, :atom do
      constraints(one_of: OrangeCms.Content.FieldType.values())
      default(:string)
    end

    attribute(:default_value, :string)

    attribute :options, {:array, :string} do
      default([])
    end

    attribute :is_required, :boolean do
      default(false)
    end
  end

  changes do
    change(set_new_attribute(:name, arg("key")), on: [:create, :update], only_when_valid?: true)
  end
end
