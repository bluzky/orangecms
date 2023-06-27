defmodule OrangeCms.ContentFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `OrangeCms.Content` context.
  """

  @doc """
  Generate a content_type.
  """
  def content_type_fixture(attrs \\ %{}) do
    {:ok, content_type} =
      attrs
      |> Enum.into(%{
        anchor_field: "some anchor_field",
        field_defs: %{},
        github_config: %{},
        image_settings: %{},
        key: "some key",
        name: "some name"
      })
      |> OrangeCms.Content.create_content_type()

    content_type
  end
end
