defmodule OrangeCms.ProjectsTest do
  use OrangeCms.DataCase

  import OrangeCms.AccountsFixtures

  alias OrangeCms.Projects
  alias OrangeCms.Projects.CreateProjectParams

  describe "projects" do
    import OrangeCms.ProjectsFixtures

    alias OrangeCms.Projects.Project

    @invalid_attrs %{github_config: nil, image: nil, name: nil, setup_completed: nil, type: nil, user_id: nil}

    test "list_projects/0 returns all projects" do
      user = random_user_fixture()
      _project = project_fixture(user)
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

      valid_attrs =
        CreateProjectParams.new(%{
          github_config: %{},
          name: "some name",
          type: :github
        })

      assert {:ok, %Project{} = project} = Projects.create_project(valid_attrs, OrangeCms.Context.new(actor: user))
      assert project.name == "some name"
      assert project.type == :github
    end

    test "create_project/1 with invalid data returns error changeset" do
      user = random_user_fixture()

      params = CreateProjectParams.new(@invalid_attrs)

      assert {:error, %Ecto.Changeset{}} =
               Projects.create_project(params, OrangeCms.Context.new(actor: user))
    end

    test "update_project/2 with valid data updates the project" do
      user = random_user_fixture()
      project = project_fixture(user)

      update_attrs = %{
        github_config: %{},
        name: "some updated name",
        setup_completed: false,
        type: :github
      }

      assert {:ok, %Project{} = project} = Projects.update_project(project, update_attrs)
      assert project.name == "some updated name"
      assert project.setup_completed == false
      assert project.type == :github
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

    @invalid_attrs %{is_owner: nil, role: nil, user_id: nil}

    test "list_project_members/0 returns all project_members" do
      user = random_user_fixture()
      project = project_fixture(user)
      user2 = random_user_fixture()
      _project_member = project_member_fixture(project, user2)
      members = Projects.list_project_members(project)
      assert [_project_member] = Enum.filter(members, fn member -> member.user_id == user2.id end)
    end

    test "get_project_member!/1 returns the project_member with given id" do
      user = random_user_fixture()
      user2 = random_user_fixture()
      project = project_fixture(user)
      project_member = project_member_fixture(project, user2)
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

      user2 = random_user_fixture()

      project_member = project_member_fixture(project, user2)
      update_attrs = %{is_owner: false, role: :admin}

      assert {:ok, %ProjectMember{} = project_member} = Projects.update_project_member(project_member, update_attrs)
      assert project_member.is_owner == false
      assert project_member.role == :admin
    end

    test "update_project_member/2 with invalid data returns error changeset" do
      user = random_user_fixture()
      user2 = random_user_fixture()
      project = project_fixture(user)
      project_member = project_member_fixture(project, user2)
      assert {:error, %Ecto.Changeset{}} = Projects.update_project_member(project_member, @invalid_attrs)
      assert project_member == Projects.get_project_member!(project_member.id)
    end

    test "delete_project_member/1 deletes the project_member" do
      user = random_user_fixture()
      user2 = random_user_fixture()
      project = project_fixture(user)
      project_member = project_member_fixture(project, user2)
      assert {:ok, %ProjectMember{}} = Projects.delete_project_member(project_member)
      assert_raise Ecto.NoResultsError, fn -> Projects.get_project_member!(project_member.id) end
    end
  end
end
