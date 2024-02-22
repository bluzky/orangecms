# result:

# - struct
# - field list
# - functions
# + new(map)
# + to_map()

defmodule CreateParams do
  @moduledoc """
  defparams CreateOrderParams do
    field :name, :string, required: true
    field :email, :string, required: true, pattern: ~r/.+@gmail.com/
    field :phone, :string, pattern: ~r/\d{3}-\d{3}-\d{4}/
    field :address, :string, default: nil
  end
  """
  @enforce_keys [:name, :email]
  defstruct name: nil, email: nil, phone: nil, address: nil

  @field_list [
    name: [type: :string, required: true],
    email: [type: :string, required: true, pattern: ~r/./],
    phone: [type: :string, pattern: ~r/./],
    address: [type: :string, default: nil]
  ]

  def new(map) do
    struct(__MODULE__, map)
  end

  # def cast(params) when is_map(params) do
  #   Tarams.cast(params, @field_list)
  # end

  def to_map(%CreateParams{} = params) do
    Map.from_struct(params)
  end

  def __schema__(:fields) do
    @field_list
  end
end

defmodule OrangeCms.Params do
  @moduledoc """
  Borrow from https://github.com/ejpcmac/typed_struct/blob/main/lib/typed_struct.ex
  """
  @accumulating_attrs [
    :ts_fields,
    :ts_types,
    :ts_enforce_keys
  ]

  @attrs_to_delete @accumulating_attrs

  @doc false
  defmacro __using__(_) do
    quote do
      import OrangeCms.Params, only: [defparams: 1, defparams: 2]
    end
  end

  @doc """
  Defines a typed struct.

  Inside a `defparams` block, each field is defined through the `field/2`
  macro.

  ## Options

    * `enforce` - if set to true, sets `enforce: true` to all fields by default.
      This can be overridden by setting `enforce: false` or a default value on
      individual fields.
    * `opaque` - if set to true, creates an opaque type for the struct.
    * `module` - if set, creates the struct in a submodule named `module`.

  ## Examples

      defmodule MyStruct do
        use OrangeCms.Params

        defparams do
          field :field_one, :string
          field :field_two, :integer, required: true
          field :field_three, :boolean, required: true
          field :field_four, :atom, default: :hey
        end
      end

  You can create the struct in a submodule instead:

      defmodule MyModule do
        use OrangeCms.Params

        defparams Struct do
          field :field_one, :string
          field :field_two, :integer, required: true
          field :field_three, :boolean, required: true
          field :field_four, :atom, default: :hey
        end
      end
  """
  defmacro defparams(module \\ nil, do: block) do
    ast = OrangeCms.Params.__typedstruct__(block)

    case module do
      nil ->
        quote do
          # Create a lexical scope.
          (fn -> unquote(ast) end).()
        end

      module ->
        quote do
          defmodule unquote(module) do
            unquote(ast)
          end
        end
    end
  end

  @doc false
  def __typedstruct__(block) do
    quote do
      import OrangeCms.Params

      Enum.each(unquote(@accumulating_attrs), fn attr ->
        Module.register_attribute(__MODULE__, attr, accumulate: true)
      end)

      @before_compile {unquote(__MODULE__), :__before_compile__}
      unquote(block)

      @enforce_keys @ts_enforce_keys
      defstruct @ts_fields

      OrangeCms.Params.__type__(@ts_types)
    end
  end

  @doc false
  defmacro __type__(types) do
    quote bind_quoted: [types: types] do
      @type t() :: %__MODULE__{unquote_splicing(types)}
    end
  end

  @doc """
  Defines a field in a typed struct.

  ## Example

      # A field named :example of type String.t()
      field :example, String.t()

  ## Options

    * `default` - sets the default value for the field
    * `enforce` - if set to true, enforces the field and makes its type
      non-nullable
  """
  defmacro field(name, type, opts \\ []) do
    quote bind_quoted: [name: name, type: Macro.escape(type), opts: opts] do
      OrangeCms.Params.__field__(name, type, opts, __ENV__)
    end
  end

  @doc false
  def __field__(name, type, opts, %Macro.Env{module: mod}) when is_atom(name) do
    if mod |> Module.get_attribute(:ts_fields) |> Keyword.has_key?(name) do
      raise ArgumentError, "the field #{inspect(name)} is already set"
    end

    has_default? = Keyword.has_key?(opts, :default)

    enforce? =
      if is_nil(opts[:required]),
        do: not has_default?,
        else: opts[:required] == true

    nullable? = not has_default? and not enforce?

    Module.put_attribute(mod, :ts_fields, {name, opts})
    Module.put_attribute(mod, :ts_types, {name, type_for(type, nullable?)})
    if enforce?, do: Module.put_attribute(mod, :ts_enforce_keys, name)
  end

  def __field__(name, _type, _opts, _env) do
    raise ArgumentError, "a field name must be an atom, got #{inspect(name)}"
  end

  # Makes the type nullable if the key is not enforced.
  defp type_for(type, false), do: type
  defp type_for(type, _), do: quote(do: unquote(type) | nil)

  @doc false
  defmacro __before_compile__(%Macro.Env{module: module}) do
    Enum.each(unquote(@attrs_to_delete), &Module.delete_attribute(module, &1))
  end
end
