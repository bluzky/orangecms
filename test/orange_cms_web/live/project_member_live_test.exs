defmodule OrangeCmsWeb.ProjectMemberLiveTest do
  use OrangeCmsWeb.ConnCase

  import OrangeCms.ProjectsFixtures
  import Phoenix.LiveViewTest

  @create_attrs %{is_owner: true, role: "some role"}
  @update_attrs %{is_owner: false, role: "some updated role"}
  @invalid_attrs %{is_owner: false, role: nil}

  defp create_project_member(_) do
    project_member = project_member_fixture()
    %{project_member: project_member}
  end

  describe "Index" do
    setup [:create_project_member]

    test "lists all project_members", %{conn: conn, project_member: project_member} do
      {:ok, _index_live, html} = live(conn, ~p"/project_members")

      assert html =~ "Listing Project users"
      assert html =~ project_member.role
    end

    test "saves new project_member", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/project_members")

      assert index_live |> element("a", "New Project user") |> render_click() =~
               "New Project user"

      assert_patch(index_live, ~p"/project_members/new")

      assert index_live
             |> form("#project_member-form", project_member: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#project_member-form", project_member: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/project_members")

      html = render(index_live)
      assert html =~ "Project user created successfully"
      assert html =~ "some role"
    end

    test "updates project_member in listing", %{conn: conn, project_member: project_member} do
      {:ok, index_live, _html} = live(conn, ~p"/project_members")

      assert index_live |> element("#project_members-#{project_member.id} a", "Edit") |> render_click() =~
               "Edit Project user"

      assert_patch(index_live, ~p"/project_members/#{project_member}/edit")

      assert index_live
             |> form("#project_member-form", project_member: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#project_member-form", project_member: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/project_members")

      html = render(index_live)
      assert html =~ "Project user updated successfully"
      assert html =~ "some updated role"
    end

    test "deletes project_member in listing", %{conn: conn, project_member: project_member} do
      {:ok, index_live, _html} = live(conn, ~p"/project_members")

      assert index_live |> element("#project_members-#{project_member.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#project_members-#{project_member.id}")
    end
  end

  describe "Show" do
    setup [:create_project_member]

    test "displays project_member", %{conn: conn, project_member: project_member} do
      {:ok, _show_live, html} = live(conn, ~p"/project_members/#{project_member}")

      assert html =~ "Show Project user"
      assert html =~ project_member.role
    end

    test "updates project_member within modal", %{conn: conn, project_member: project_member} do
      {:ok, show_live, _html} = live(conn, ~p"/project_members/#{project_member}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Project user"

      assert_patch(show_live, ~p"/project_members/#{project_member}/show/edit")

      assert show_live
             |> form("#project_member-form", project_member: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#project_member-form", project_member: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/project_members/#{project_member}")

      html = render(show_live)
      assert html =~ "Project user updated successfully"
      assert html =~ "some updated role"
    end
  end
end
