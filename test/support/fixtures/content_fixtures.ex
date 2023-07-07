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
        frontmatter_schema: %{},
        github_config: %{},
        github_config: %{},
        key: "some key",
        name: "some name"
      })
      |> OrangeCms.Content.create_content_type()

    content_type
  end

  @doc """
  Generate a content_entry.
  """
  def content_entry_fixture(attrs \\ %{}) do
    {:ok, content_entry} =
      attrs
      |> Enum.into(%{
        frontmatter: "some frontmatter",
        integration_info: "some integration_info",
        json_body: "some json_body",
        raw_body: "some raw_body",
        slug: "some slug",
        title: "some title"
      })
      |> OrangeCms.Content.create_content_entry()

    content_entry
  end
end
