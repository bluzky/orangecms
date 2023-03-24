defmodule OrangeCms.Content.FieldDef do
  use Ash.Resource,
    data_layer: :embedded

  attributes do
    attribute(:name, :string)

    attribute :key, :string do
      allow_nil?(false)
    end

    attribute :type, :atom do
      constraints(one_of: OrangeCms.Content.InputType.values())
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

  def cast_field(field, value) do
    Ash.Type.cast_input(OrangeCms.Content.InputType.stored_type(field.type), value)
  end

  def default_value(field) do
    case field do
      %{default_value: nil} ->
        nil

      %{type: :string} ->
        ## render template string with datetime 
        Calendar.strftime(DateTime.utc_now(), field.default_value)

      %{type: :date, default_value: "today()"} ->
        Date.utc_today()

      %{type: :datetime, default_value: "now()"} ->
        NaiveDateTime.utc_now()

      _ ->
        case cast_field(field, field.default_value) do
          {:ok, value} ->
            value

          _error ->
            IO.inspect(field)
            nil
        end
    end
  end
end

defmodule OrangeCms.Content.FieldDef.SplitOption do
  use Ash.Calculation

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
