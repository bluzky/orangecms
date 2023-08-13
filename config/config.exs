# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :orange_cms,
  ecto_repos: [OrangeCms.Repo]

# Configures the endpoint
config :orange_cms, OrangeCmsWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: OrangeCmsWeb.ErrorHTML, json: OrangeCmsWeb.ErrorJSON],
    root_layout: {OrangeCmsWeb.Layouts, :root},
    layout: {OrangeCmsWeb.Layouts, :app}
  ],
  pubsub_server: OrangeCms.PubSub,
  live_view: [signing_salt: "iFmLWv47"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :orange_cms, OrangeCms.Mailer, adapter: Swoosh.Adapters.Local

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.2.4",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :tails, colors_file: Path.join(File.cwd!(), "assets/colors.json")

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
