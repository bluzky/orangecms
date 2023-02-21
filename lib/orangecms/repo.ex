defmodule Orangecms.Repo do
  use Ecto.Repo,
    otp_app: :orangecms,
    adapter: Ecto.Adapters.Postgres
end
