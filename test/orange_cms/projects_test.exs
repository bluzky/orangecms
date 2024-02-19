defmodule OrangeCms.ProjectsTest do
  use OrangeCms.DataCase

  import OrangeCms.AccountsFixtures

  alias OrangeCms.Projects

  describe "projects" do
    import OrangeCms.ProjectsFixtures

    alias OrangeCms.Projects.Project

    @invalid_attrs %{github_config: nil, image: nil, name: nil, setup_completed: nil, type: nil}

    test "list_projects/0 returns all projects" do
      user = random_user_fixture()
      project = project_fixture(user)
      assert [_project] = Projects.list_user_projects(user)
    end

    test "get_project!/1 returns the project with given id" do
      user = random_user_fixture()
      project = project_fixture(user)

      p = Projects.get_project!(project.id)
      assert p.id == project.id
    end

    test "create_project/1 with valid data creates a project" do
      user = random_user_fixture()

      valid_attrs = %{
        github_config: %{},
        image: "some image",
        name: "some name",
        setup_completed: true,
        type: :github
      }

      assert {:ok, %Project{} = project} = Projects.create_project(valid_attrs, user)
      assert project.image == "some image"
      assert project.name == "some name"
      assert project.setup_completed == true
      assert project.type == "some type"
    end

    test "create_project/1 with invalid data returns error changeset" do
      user = random_user_fixture()

      assert {:error, %Ecto.Changeset{}} = Projects.create_project(@invalid_attrs, user)
    end

    test "update_project/2 with valid data updates the project" do
      user = random_user_fixture()
      project = project_fixture(user)

      update_attrs = %{
        github_config: %{},
        image: "some updated image",
        name: "some updated name",
        setup_completed: false,
        type: "some updated type"
      }

      assert {:ok, %Project{} = project} = Projects.update_project(project, update_attrs)
      assert project.github_config == %{}
      assert project.image == "some updated image"
      assert project.name == "some updated name"
      assert project.setup_completed == false
      assert project.type == "some updated type"
    end

    test "update_project/2 with invalid data returns error changeset" do
      user = random_user_fixture()
      project = project_fixture(user)
      assert {:error, %Ecto.Changeset{}} = Projects.update_project(project, @invalid_attrs)
      assert %{id: id} = Projects.get_project!(project.id)
      assert id == project.id
    end
  end

  describe "project_members" do
    import OrangeCms.ProjectsFixtures

    alias OrangeCms.Projects.ProjectMember

    @invalid_attrs %{is_owner: nil, role: nil}

    test "list_project_members/0 returns all project_members" do
      user = random_user_fixture()
      project = project_fixture(user)
      project_member = project_member_fixture(project, user)
      assert Projects.list_project_members(project) == [project_member]
    end

    test "get_project_member!/1 returns the project_member with given id" do
      user = random_user_fixture()
      project = project_fixture(user)
      project_member = project_member_fixture(project, user)
      assert Projects.get_project_member!(project_member.id) == project_member
    end

    test "add_project_member/1 with valid data creates a project_member" do
      user = random_user_fixture()
      project = project_fixture(user)
      user2 = random_user_fixture()

      valid_attrs = %{is_owner: true, role: :editor, user_id: user2.id}

      assert {:ok, %ProjectMember{} = project_member} = Projects.add_project_member(project, valid_attrs)
      assert project_member.is_owner == true
      assert project_member.role == :editor
      assert project_member.user_id == user2.id
    end

    test "create_project_member/1 with invalid data returns error changeset" do
      user = random_user_fixture()
      project = project_fixture(user)

      assert {:error, %Ecto.Changeset{}} = Projects.add_project_member(project, @invalid_attrs)
    end

    test "update_project_member/2 with valid data updates the project_member" do
      user = random_user_fixture()
      project = project_fixture(user)

      project_member = project_member_fixture(project, user)
      update_attrs = %{is_owner: false, role: "some updated role"}

      assert {:ok, %ProjectMember{} = project_member} = Projects.update_project_member(project_member, update_attrs)
      assert project_member.is_owner == false
      assert project_member.role == "some updated role"
    end

    test "update_project_member/2 with invalid data returns error changeset" do
      user = random_user_fixture()
      project = project_fixture(user)
      project_member = project_member_fixture(project, user)
      assert {:error, %Ecto.Changeset{}} = Projects.update_project_member(project_member, @invalid_attrs)
      assert project_member == Projects.get_project_member!(project_member.id)
    end

    test "delete_project_member/1 deletes the project_member" do
      user = random_user_fixture()
      project = project_fixture(user)
      project_member = project_member_fixture(project, user)
      assert {:ok, %ProjectMember{}} = Projects.delete_project_member(project_member)
      assert_raise Ecto.NoResultsError, fn -> Projects.get_project_member!(project_member.id) end
    end
  end
end
