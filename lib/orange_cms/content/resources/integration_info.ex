defmodule OrangeCms.Content.ContentGithubInfo do
  use Ash.Resource,
    data_layer: :embedded

  attributes do
    attribute(:name, :string)
    # relative path under content_type's content_dir
    attribute(:relative_path, :string)
    attribute(:full_path, :string)
    attribute(:sha, :string)
  end
end
