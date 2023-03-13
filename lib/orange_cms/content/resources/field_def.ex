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

    attribute(:options_str, :string, default: "")

    attribute :is_required, :boolean do
      default(false)
    end
  end

  changes do
    change(set_new_attribute(:name, arg("key")), on: [:create, :update], only_when_valid?: true)
  end

  calculations do
    calculate(:options, {:array, :string}, OrangeCms.Content.FieldDef.SplitOption)
  end
end

defmodule OrangeCms.Content.FieldDef.SplitOption do
  use Ash.Resource.Change

  @impl true
  def select(_query, _opts, _context) do
    [:options_str]
  end

  @impl true
  def load(_query, _opts, _context) do
    [:options_str]
  end

  @impl true
  def calculate(records, _opts, _context) do
    Enum.map(records, fn record ->
      record.options_str
      |> Kernel.||("")
      |> String.split(",")
      |> Enum.map(&String.trim/1)
    end)
  end
end
