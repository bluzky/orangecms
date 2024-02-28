defmodule OrangeCms.Projects.CreateProjectParams do
  @moduledoc false
  use Skema

  defschema do
    field :name, :string, required: true
    field :type, :atom, default: :github, in: [:github, :headless_cms]
  end
end
