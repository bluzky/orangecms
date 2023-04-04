defmodule OrangeCms.Content.ImageUploadSettings do
  use Ash.Resource,
    data_layer: :embedded

  attributes do
    attribute(:upload_dir, :string, default: "/public")

    attribute(:serve_at, :string) do
      default("/")
    end

    attribute :use_raw_link, :boolean do
      default(false)
    end
  end
end
