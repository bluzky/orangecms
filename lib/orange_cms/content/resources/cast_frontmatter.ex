defmodule OrangeCms.Content.CastFrontmatter do
  @moduledoc false
  alias Ecto.Changeset
  alias OrangeCms.Content.FieldDef

  def change(changeset, content_type) do
    frontmatter_params = Changeset.get_field(changeset, :frontmatter) || %{}
    # cast field value based on schema

    field_map = Map.new(content_type.field_defs, &{&1.key, &1})

    # get default values
    frontmatter_default =
      Map.new(content_type.field_defs, fn field -> {field.key, OrangeCms.Content.FieldDef.default_value(field)} end)

    # cast value from params
    frontmatter_params =
      frontmatter_params
      |> Enum.map(fn {k, v} ->
        case field_map[k] do
          nil ->
            # keep undefined field
            {k, v}

          field ->
            # handle error later
            case FieldDef.cast_field(field, v) do
              {:ok, value} -> {k, value}
              _error -> {k, nil}
            end
        end
      end)
      |> Enum.reject(fn {_, v} -> is_nil(v) end)
      |> Map.new()

    # merge default values with values from params
    # this will override default values
    Changeset.put_change(
      changeset,
      :frontmatter,
      Map.merge(frontmatter_default, frontmatter_params)
    )
  end
end
