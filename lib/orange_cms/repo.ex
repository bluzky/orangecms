defmodule OrangeCms.Repo do
  # use Ecto.Repo,
  #   otp_app: :orange_cms,
  #   adapter: Ecto.Adapters.Postgres

  use AshPostgres.Repo, otp_app: :orange_cms

  # Installs Postgres extensions that ash commonly uses
  def installed_extensions do
    ["uuid-ossp", "citext"]
  end
end
