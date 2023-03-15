defmodule OrangeCms.Projects.ProjectType do
  use Ash.Type.Enum,
    values: [:headless_cms, :github]
end
