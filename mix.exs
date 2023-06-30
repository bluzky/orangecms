defmodule OrangeCms.MixProject do
  use Mix.Project

  def project do
    [
      app: :orange_cms,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {OrangeCms.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:bcrypt_elixir, "~> 3.0"},
      {:phoenix, "~> 1.7.0"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.6"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 3.3"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.18.16"},
      {:heroicons, "~> 0.5"},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.7.2"},
      {:esbuild, "~> 0.5", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2.1", runtime: Mix.env() == :dev},
      {:swoosh, "~> 1.3"},
      {:finch, "~> 0.13"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      # {:eva_icons, github: "bluzky/eva_icons", branch: "main"}
      {:lucide_icons, "~> 1.0.0"},
      {:nanoid, "~> 2.0"},
      {:tentacat, "~> 2.2"},
      {:yaml_elixir, "~> 2.9"},
      {:slugger, "~> 0.3.0"},
      {:filtery, "~> 0.2.3"},
      {:dialyxir, "~> 1.3", only: [:dev], runtime: false},
      {:styler, "~> 0.7", only: [:dev, :test], runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "db.setup", "assets.setup", "assets.build"],
      "db.setup": ["ash_postgres.create", "ash_postgres.migrate", "run priv/repo/seeds.exs"],
      "db.reset": ["ash_postgres.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "cmd \"cd assets && yarn && cd -\""],
      "assets.build": ["tailwind default", "cmd \"cd assets && yarn build && cd -\""],
      "assets.deploy": [
        "tailwind default --minify",
        "cmd \"cd assets && yarn build && cd -\"",
        "phx.digest"
      ]
    ]
  end
end
