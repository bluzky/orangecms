defmodule OrangeCms.Content.CastFrontmatter do
  use Ash.Resource.Change

  alias Ash.Changeset
  alias OrangeCms.Content.FieldDef

  @impl true
  def change(changeset, _opts, _context) do
    content_type = Changeset.get_data(changeset, :content_type)
    frontmatter_params = Changeset.get_argument_or_attribute(changeset, :frontmatter) || %{}

    # cast field value based on schema

    field_map = Enum.into(content_type.field_defs, %{}, &{&1.key, &1})

    frontmatter_params =
      Enum.map(frontmatter_params, fn {k, v} ->
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
      |> Enum.into(%{})

    Changeset.change_attribute(changeset, :frontmatter, frontmatter_params)
  end
end
