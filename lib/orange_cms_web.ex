defmodule OrangeCmsWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.

  This can be used in your application as:

      use OrangeCmsWeb, :controller
      use OrangeCmsWeb, :html

  The definitions below will be executed for every controller,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """

  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  def router do
    quote do
      use Phoenix.Router, helpers: true

      # Import common connection and controller functions to use in pipelines
      import Phoenix.Controller
      import Phoenix.LiveView.Router
      import Plug.Conn
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def controller do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json],
        layouts: [html: OrangeCmsWeb.Layouts]

      import OrangeCmsWeb.Gettext
      import Plug.Conn

      unquote(verified_routes())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {OrangeCmsWeb.Layouts, :app}

      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())
    end
  end

  def html do
    quote do
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # HTML escaping functionality
      # Core UI components and translation
      import OrangeCmsWeb.Components.Card
      import OrangeCmsWeb.Components.Dialog
      import OrangeCmsWeb.Components.DropdownMenu
      import OrangeCmsWeb.Components.Form
      import OrangeCmsWeb.Components.Input, except: [input: 1]
      import OrangeCmsWeb.Components.JS
      import OrangeCmsWeb.Components.Table
      import OrangeCmsWeb.Components.Tooltip
      import OrangeCmsWeb.Components.Display
      import OrangeCmsWeb.CoreComponents
      import OrangeCmsWeb.Gettext
      import OrangeCmsWeb.ViewHelper
      import Phoenix.HTML

      alias OrangeCmsWeb.Components.Input

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS

      # Routes generation with the ~p sigil
      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: OrangeCmsWeb.Endpoint,
        router: OrangeCmsWeb.Router,
        statics: OrangeCmsWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
