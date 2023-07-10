defmodule OrangeCms.ProjectsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `OrangeCms.Projects` context.
  """

  @doc """
  Generate a project.
  """
  def project_fixture(attrs \\ %{}) do
    {:ok, project} =
      attrs
      |> Enum.into(%{
        github_config: %{},
        image: "some image",
        name: "some name",
        setup_completed: true,
        type: "some type"
      })
      |> OrangeCms.Projects.create_project()

    project
  end

  @doc """
  Generate a project_member.
  """
  def project_member_fixture(attrs \\ %{}) do
    {:ok, project_member} =
      attrs
      |> Enum.into(%{
        is_owner: true,
        role: "some role"
      })
      |> OrangeCms.Projects.create_project_member()

    project_member
  end
end
