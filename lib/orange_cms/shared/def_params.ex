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

  ## Examples

      defmodule MyStruct do
        use OrangeCms.Params

        defparams do
          field :field_one, :string
          field :field_two, :integer, required: true
          field :field_three, :boolean, required: true
          field :field_four, :atom, default: :hey
          field :update_time, :naive_datetime, default: &NaiveDateTime.utc_now/0
        end
      end

  You can create the struct in a submodule instead:

      defmodule MyModule do
        use OrangeCms.Params

        defparams Comment do
          field :user_id, :integer, required: true
          field :content, :string, required: true
        end

        defparams Post do
          field :field_one, :string
          field :field_two, :integer, required: true
          field :field_three, :boolean, required: true
          field :field_four, :string, default: "hello"
          field :update_time, :naive_datetime, default: &NaiveDateTime.utc_now/0
          field :comment, Comment, required: true
        end
      end

      MyModule.Post.cast(%{field_two: 1, field_three: true, comment: %{user_id: 1, content: "hello"}})

  """
  defmacro defparams(module \\ nil, do: block) do
    ast = OrangeCms.Params.__typedstruct__(block)
    method_ast = OrangeCms.Params.__default_functions__()

    case module do
      nil ->
        quote do
          # Create a lexical scope.
          (fn -> unquote(ast) end).()
          unquote(method_ast)
        end

      module ->
        quote do
          defmodule unquote(module) do
            unquote(ast)

            unquote(method_ast)
          end
        end
    end
  end

  def __default_functions__ do
    quote do
      def new(map) do
        struct(__MODULE__, map)
      end

      def cast(params) when is_map(params) do
        case Tarams.cast(params, @ts_fields) do
          {:ok, params} -> {:ok, new(params)}
          {:error, errors} -> {:error, errors}
        end
      end

      def __schema__(:fields) do
        @ts_fields
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
    quote bind_quoted: [name: name, type: type, opts: opts] do
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

    Module.put_attribute(mod, :ts_fields, {name, [{:type, type} | opts]})
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
