defmodule OrangeCms.Projects.CreateProjectParams do
  @moduledoc false
  use OrangeCms.Params

  defparams do
    field :name, :string, required: true
    field :type, :any, default: "github", in: ["github", "headless_cms", :github, :headless_cms]
  end
end
