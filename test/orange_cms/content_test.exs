defmodule OrangeCms.ContentTest do
  use OrangeCms.DataCase

  alias OrangeCms.Content

  describe "content_types" do
    alias OrangeCms.Content.ContentType

    import OrangeCms.ContentFixtures

    @invalid_attrs %{anchor_field: nil, field_defs: nil, github_config: nil, image_settings: nil, key: nil, name: nil}

    test "list_content_types/0 returns all content_types" do
      content_type = content_type_fixture()
      assert Content.list_content_types() == [content_type]
    end

    test "get_content_type!/1 returns the content_type with given id" do
      content_type = content_type_fixture()
      assert Content.get_content_type!(content_type.id) == content_type
    end

    test "create_content_type/1 with valid data creates a content_type" do
      valid_attrs = %{anchor_field: "some anchor_field", field_defs: %{}, github_config: %{}, image_settings: %{}, key: "some key", name: "some name"}

      assert {:ok, %ContentType{} = content_type} = Content.create_content_type(valid_attrs)
      assert content_type.anchor_field == "some anchor_field"
      assert content_type.field_defs == %{}
      assert content_type.github_config == %{}
      assert content_type.image_settings == %{}
      assert content_type.key == "some key"
      assert content_type.name == "some name"
    end

    test "create_content_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_content_type(@invalid_attrs)
    end

    test "update_content_type/2 with valid data updates the content_type" do
      content_type = content_type_fixture()
      update_attrs = %{anchor_field: "some updated anchor_field", field_defs: %{}, github_config: %{}, image_settings: %{}, key: "some updated key", name: "some updated name"}

      assert {:ok, %ContentType{} = content_type} = Content.update_content_type(content_type, update_attrs)
      assert content_type.anchor_field == "some updated anchor_field"
      assert content_type.field_defs == %{}
      assert content_type.github_config == %{}
      assert content_type.image_settings == %{}
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
end
