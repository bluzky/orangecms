defmodule OrangeCms.Projects.Registry do
  use Ash.Registry,
    extensions: [
      Ash.Registry.ResourceValidations
    ]

  entries do
    entry(OrangeCms.Projects.Project)
    entry(OrangeCms.Projects.ProjectUser)
  end
end
