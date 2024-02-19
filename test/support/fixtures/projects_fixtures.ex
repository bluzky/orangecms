defmodule OrangeCms.ProjectsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `OrangeCms.Projects` context.
  """

  @doc """
  Generate a project.
  """
  def project_fixture(creator, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        github_config: %{},
        image: "some image",
        name: "some name",
        setup_completed: true,
        type: :headless_cms
      })

    {:ok, project} =
      OrangeCms.Projects.create_project(attrs, creator)

    project
  end

  @doc """
  Generate a project_member.
  """
  def project_member_fixture(project, user, attrs \\ %{}) do
    params = Enum.into(attrs, %{is_owner: true, role: :admin, user_id: user.id})

    {:ok, project_member} =
      OrangeCms.Projects.add_project_member(project, params)

    project_member
  end
end
