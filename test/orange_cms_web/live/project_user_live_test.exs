defmodule OrangeCmsWeb.ProjectUserLiveTest do
  use OrangeCmsWeb.ConnCase

  import Phoenix.LiveViewTest
  import OrangeCms.ProjectsFixtures

  @create_attrs %{is_owner: true, role: "some role"}
  @update_attrs %{is_owner: false, role: "some updated role"}
  @invalid_attrs %{is_owner: false, role: nil}

  defp create_project_user(_) do
    project_user = project_user_fixture()
    %{project_user: project_user}
  end

  describe "Index" do
    setup [:create_project_user]

    test "lists all project_users", %{conn: conn, project_user: project_user} do
      {:ok, _index_live, html} = live(conn, ~p"/project_users")

      assert html =~ "Listing Project users"
      assert html =~ project_user.role
    end

    test "saves new project_user", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/project_users")

      assert index_live |> element("a", "New Project user") |> render_click() =~
               "New Project user"

      assert_patch(index_live, ~p"/project_users/new")

      assert index_live
             |> form("#project_user-form", project_user: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#project_user-form", project_user: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/project_users")

      html = render(index_live)
      assert html =~ "Project user created successfully"
      assert html =~ "some role"
    end

    test "updates project_user in listing", %{conn: conn, project_user: project_user} do
      {:ok, index_live, _html} = live(conn, ~p"/project_users")

      assert index_live |> element("#project_users-#{project_user.id} a", "Edit") |> render_click() =~
               "Edit Project user"

      assert_patch(index_live, ~p"/project_users/#{project_user}/edit")

      assert index_live
             |> form("#project_user-form", project_user: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#project_user-form", project_user: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/project_users")

      html = render(index_live)
      assert html =~ "Project user updated successfully"
      assert html =~ "some updated role"
    end

    test "deletes project_user in listing", %{conn: conn, project_user: project_user} do
      {:ok, index_live, _html} = live(conn, ~p"/project_users")

      assert index_live |> element("#project_users-#{project_user.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#project_users-#{project_user.id}")
    end
  end

  describe "Show" do
    setup [:create_project_user]

    test "displays project_user", %{conn: conn, project_user: project_user} do
      {:ok, _show_live, html} = live(conn, ~p"/project_users/#{project_user}")

      assert html =~ "Show Project user"
      assert html =~ project_user.role
    end

    test "updates project_user within modal", %{conn: conn, project_user: project_user} do
      {:ok, show_live, _html} = live(conn, ~p"/project_users/#{project_user}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Project user"

      assert_patch(show_live, ~p"/project_users/#{project_user}/show/edit")

      assert show_live
             |> form("#project_user-form", project_user: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#project_user-form", project_user: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/project_users/#{project_user}")

      html = render(show_live)
      assert html =~ "Project user updated successfully"
      assert html =~ "some updated role"
    end
  end
end
