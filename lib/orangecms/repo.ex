defmodule OrangeCms.Repo do
  use AshPostgres.Repo, otp_app: :orange_cms

  # Installs Postgres extensions that ash commonly uses
  def installed_extensions do
    ["uuid-ossp", "citext"]
  end
end
