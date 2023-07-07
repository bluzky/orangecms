defmodule OrangeCmsWeb.ContentEntryLiveTest do
  use OrangeCmsWeb.ConnCase

  import OrangeCms.ContentFixtures
  import Phoenix.LiveViewTest

  @create_attrs %{
    frontmatter: "some frontmatter",
    integration_info: "some integration_info",
    json_body: "some json_body",
    body: "some body",
    slug: "some slug",
    title: "some title"
  }
  @update_attrs %{
    frontmatter: "some updated frontmatter",
    integration_info: "some updated integration_info",
    json_body: "some updated json_body",
    body: "some updated body",
    slug: "some updated slug",
    title: "some updated title"
  }
  @invalid_attrs %{frontmatter: nil, integration_info: nil, json_body: nil, body: nil, slug: nil, title: nil}

  defp create_content_entry(_) do
    content_entry = content_entry_fixture()
    %{content_entry: content_entry}
  end

  describe "Index" do
    setup [:create_content_entry]

    test "lists all content_entries", %{conn: conn, content_entry: content_entry} do
      {:ok, _index_live, html} = live(conn, ~p"/content_entries")

      assert html =~ "Listing Content entries"
      assert html =~ content_entry.frontmatter
    end

    test "saves new content_entry", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/content_entries")

      assert index_live |> element("a", "New Content entry") |> render_click() =~
               "New Content entry"

      assert_patch(index_live, ~p"/content_entries/new")

      assert index_live
             |> form("#content_entry-form", content_entry: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#content_entry-form", content_entry: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/content_entries")

      html = render(index_live)
      assert html =~ "Content entry created successfully"
      assert html =~ "some frontmatter"
    end

    test "updates content_entry in listing", %{conn: conn, content_entry: content_entry} do
      {:ok, index_live, _html} = live(conn, ~p"/content_entries")

      assert index_live |> element("#content_entries-#{content_entry.id} a", "Edit") |> render_click() =~
               "Edit Content entry"

      assert_patch(index_live, ~p"/content_entries/#{content_entry}/edit")

      assert index_live
             |> form("#content_entry-form", content_entry: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#content_entry-form", content_entry: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/content_entries")

      html = render(index_live)
      assert html =~ "Content entry updated successfully"
      assert html =~ "some updated frontmatter"
    end

    test "deletes content_entry in listing", %{conn: conn, content_entry: content_entry} do
      {:ok, index_live, _html} = live(conn, ~p"/content_entries")

      assert index_live |> element("#content_entries-#{content_entry.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#content_entries-#{content_entry.id}")
    end
  end

  describe "Show" do
    setup [:create_content_entry]

    test "displays content_entry", %{conn: conn, content_entry: content_entry} do
      {:ok, _show_live, html} = live(conn, ~p"/content_entries/#{content_entry}")

      assert html =~ "Show Content entry"
      assert html =~ content_entry.frontmatter
    end

    test "updates content_entry within modal", %{conn: conn, content_entry: content_entry} do
      {:ok, show_live, _html} = live(conn, ~p"/content_entries/#{content_entry}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Content entry"

      assert_patch(show_live, ~p"/content_entries/#{content_entry}/show/edit")

      assert show_live
             |> form("#content_entry-form", content_entry: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#content_entry-form", content_entry: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/content_entries/#{content_entry}")

      html = render(show_live)
      assert html =~ "Content entry updated successfully"
      assert html =~ "some updated frontmatter"
    end
  end
end
