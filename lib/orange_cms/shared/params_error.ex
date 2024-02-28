defimpl Phoenix.HTML.FormData, for: Skema.Result do
  @impl true
  def to_form(error, opts) do
    %Phoenix.HTML.Form{
      source: error,
      impl: __MODULE__,
      id: opts[:id],
      name: opts[:as],
      errors: error.errors,
      data: %{},
      params: error.data,
      hidden: [],
      options: opts
    }
  end

  @impl true
  def to_form(error, form, field, options) do
    {prepend, options} = Keyword.pop(options, :prepend, [])
    {append, options} = Keyword.pop(options, :append, [])
    {name, options} = Keyword.pop(options, :as)
    {id, options} = Keyword.pop(options, :id)

    id = to_string(id || form.id <> "_#{field}")
    name = to_string(name || form.name <> "[#{field}]")

    case error.data do
      %{^field => values} when is_list(values) ->
        Enum.map(
          prepend ++ values ++ append,
          &%Phoenix.HTML.Form{
            source: &1,
            impl: __MODULE__,
            id: id,
            name: name,
            errors: [],
            data: &1,
            params: &1,
            options: options
          }
        )

      %{^field => value} when is_map(value) ->
        [
          %Phoenix.HTML.Form{
            source: value,
            impl: __MODULE__,
            id: id,
            name: name,
            errors: [],
            data: value,
            params: value,
            options: options
          }
        ]

      %{^field => _value} ->
        raise "data.#{field} is not a list nor a map"
    end
  end

  @impl true
  def input_value(data, _form, field) do
    case data do
      %{^field => value} ->
        value

      _missing ->
        raise "Invalid filter form field #{field}."
    end
  end

  @impl true
  def input_type(_data, _form, _field), do: nil

  @impl true
  def input_validations(_, _, _), do: []
end
