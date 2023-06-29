defmodule OrangeCms.Projects.ProjectType do
  @moduledoc false
  use Ash.Type.Enum,
    values: [:headless_cms, :github]
end
