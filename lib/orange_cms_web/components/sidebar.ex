defmodule OrangeCmsWeb.Components.Sidebar do
  @moduledoc """
  Provides core UI components.

  The components in this module use Tailwind CSS, a utility-first CSS framework.
  See the [Tailwind CSS documentation](https://tailwindcss.com) to learn how to
  customize the generated components in this module.

  Icons are provided by [heroicons](https://heroicons.com), using the
  [heroicons_elixir](https://github.com/mveytsman/heroicons_elixir) project.
  """
  use Phoenix.Component
  use OrangeCmsWeb, :verified_routes

  import OrangeCmsWeb.ViewHelper
  import OrangeCmsWeb.CoreComponents
  import OrangeCmsWeb.Components.DropdownMenu


  embed_templates "sidebar/*"

end
