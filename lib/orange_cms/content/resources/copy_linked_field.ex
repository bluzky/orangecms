defmodule OrangeCms.Content.CopyLinkedField do
  @moduledoc """
  Copy linked field with the same name from frontmatter to entry field
  """
  use Ash.Resource.Change

  alias Ash.Changeset

  @impl true
  def change(changeset, [fields: fields], _context) do
    frontmatter = Changeset.get_argument_or_attribute(changeset, :frontmatter) || %{}

    {changeset, frontmatter} =
      Enum.reduce(fields, {changeset, frontmatter}, fn field, {changeset, frontmatter} ->
        case Map.fetch(frontmatter, to_string(field)) do
          :error ->
            {changeset, frontmatter}

          {:ok, nil} ->
            value = Changeset.get_attribute(changeset, field)
            {changeset, Map.put(frontmatter, to_string(field), value)}

          {:ok, value} ->
            {Changeset.change_attribute(changeset, field, value), frontmatter}
        end
      end)

    Changeset.set_argument(changeset, :frontmatter, frontmatter)
  end
end
