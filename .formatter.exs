[
  import_deps: [
    :ecto,
    :ecto_sql,
    :phoenix,
    :ash_authentication,
    :ash_authentication_phoenix,
    :ash_postgres,
    :ash
  ],
  subdirectories: ["priv/*/migrations"],
  plugins: [Phoenix.LiveView.HTMLFormatter],
  inputs: ["*.{heex,ex,exs}", "{config,lib,test}/**/*.{heex,ex,exs}", "priv/*/seeds.exs"]
]
