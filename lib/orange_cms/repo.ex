defmodule OrangeCms.Repo do
  use Ecto.Repo,
    otp_app: :orange_cms,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 10
end
