defmodule OrangeCms.ContentTest do
  use OrangeCms.DataCase

  alias OrangeCms.Content

  describe "content_types" do
    import OrangeCms.ContentFixtures

    alias OrangeCms.Content.ContentType

    @invalid_attrs %{anchor_field: nil, frontmatter_schema: nil, github_config: nil, github_config: nil, key: nil, name: nil}

    test "list_content_types/0 returns all content_types" do
      content_type = content_type_fixture()
      assert Content.list_content_types() == [content_type]
    end

    test "get_content_type!/1 returns the content_type with given id" do
      content_type = content_type_fixture()
      assert Content.get_content_type!(content_type.id) == content_type
    end

    test "create_content_type/1 with valid data creates a content_type" do
      valid_attrs = %{
        anchor_field: "some anchor_field",
        frontmatter_schema: %{},
        github_config: %{},
        github_config: %{},
        key: "some key",
        name: "some name"
      }

      assert {:ok, %ContentType{} = content_type} = Content.create_content_type(valid_attrs)
      assert content_type.anchor_field == "some anchor_field"
      assert content_type.frontmatter_schema == %{}
      assert content_type.github_config == %{}
      assert content_type.github_config == %{}
      assert content_type.key == "some key"
      assert content_type.name == "some name"
    end

    test "create_content_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_content_type(@invalid_attrs)
    end

    test "update_content_type/2 with valid data updates the content_type" do
      content_type = content_type_fixture()

      update_attrs = %{
        anchor_field: "some updated anchor_field",
        frontmatter_schema: %{},
        github_config: %{},
        github_config: %{},
        key: "some updated key",
        name: "some updated name"
      }

      assert {:ok, %ContentType{} = content_type} = Content.update_content_type(content_type, update_attrs)
      assert content_type.anchor_field == "some updated anchor_field"
      assert content_type.frontmatter_schema == %{}
      assert content_type.github_config == %{}
      assert content_type.github_config == %{}
      assert content_type.key == "some updated key"
      assert content_type.name == "some updated name"
    end

    test "update_content_type/2 with invalid data returns error changeset" do
      content_type = content_type_fixture()
      assert {:error, %Ecto.Changeset{}} = Content.update_content_type(content_type, @invalid_attrs)
      assert content_type == Content.get_content_type!(content_type.id)
    end

    test "delete_content_type/1 deletes the content_type" do
      content_type = content_type_fixture()
      assert {:ok, %ContentType{}} = Content.delete_content_type(content_type)
      assert_raise Ecto.NoResultsError, fn -> Content.get_content_type!(content_type.id) end
    end

    test "change_content_type/1 returns a content_type changeset" do
      content_type = content_type_fixture()
      assert %Ecto.Changeset{} = Content.change_content_type(content_type)
    end
  end

  describe "content_entries" do
    import OrangeCms.ContentFixtures

    alias OrangeCms.Content.ContentEntry

    @invalid_attrs %{frontmatter: nil, integration_info: nil, json_body: nil, body: nil, slug: nil, title: nil}

    test "list_content_entries/0 returns all content_entries" do
      content_entry = content_entry_fixture()
      assert Content.list_content_entries() == [content_entry]
    end

    test "get_content_entry!/1 returns the content_entry with given id" do
      content_entry = content_entry_fixture()
      assert Content.get_content_entry!(content_entry.id) == content_entry
    end

    test "create_content_entry/1 with valid data creates a content_entry" do
      valid_attrs = %{
        frontmatter: "some frontmatter",
        integration_info: "some integration_info",
        json_body: "some json_body",
        body: "some body",
        slug: "some slug",
        title: "some title"
      }

      assert {:ok, %ContentEntry{} = content_entry} = Content.create_content_entry(valid_attrs)
      assert content_entry.frontmatter == "some frontmatter"
      assert content_entry.integration_info == "some integration_info"
      assert content_entry.json_body == "some json_body"
      assert content_entry.body == "some body"
      assert content_entry.slug == "some slug"
      assert content_entry.title == "some title"
    end

    test "create_content_entry/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_content_entry(@invalid_attrs)
    end

    test "update_content_entry/2 with valid data updates the content_entry" do
      content_entry = content_entry_fixture()

      update_attrs = %{
        frontmatter: "some updated frontmatter",
        integration_info: "some updated integration_info",
        json_body: "some updated json_body",
        body: "some updated body",
        slug: "some updated slug",
        title: "some updated title"
      }

      assert {:ok, %ContentEntry{} = content_entry} = Content.update_content_entry(content_entry, update_attrs)
      assert content_entry.frontmatter == "some updated frontmatter"
      assert content_entry.integration_info == "some updated integration_info"
      assert content_entry.json_body == "some updated json_body"
      assert content_entry.body == "some updated body"
      assert content_entry.slug == "some updated slug"
      assert content_entry.title == "some updated title"
    end

    test "update_content_entry/2 with invalid data returns error changeset" do
      content_entry = content_entry_fixture()
      assert {:error, %Ecto.Changeset{}} = Content.update_content_entry(content_entry, @invalid_attrs)
      assert content_entry == Content.get_content_entry!(content_entry.id)
    end

    test "delete_content_entry/1 deletes the content_entry" do
      content_entry = content_entry_fixture()
      assert {:ok, %ContentEntry{}} = Content.delete_content_entry(content_entry)
      assert_raise Ecto.NoResultsError, fn -> Content.get_content_entry!(content_entry.id) end
    end

    test "change_content_entry/1 returns a content_entry changeset" do
      content_entry = content_entry_fixture()
      assert %Ecto.Changeset{} = Content.change_content_entry(content_entry)
    end
  end
end
