defmodule OrangeCmsWeb.ViewHelper do
  @moduledoc false
  use OrangeCmsWeb, :verified_routes

  def scoped_path(socket_or_conn_or_assigns, relative_path, params \\ %{})

  def scoped_path(%{assigns: assigns} = socket, relative_path, params) do
    scoped_path(socket, assigns, relative_path, params)
  end

  def scoped_path(assigns, relative_path, params) do
    scoped_path(assigns.socket, assigns, relative_path, params)
  end

  def scoped_path(socket_or_conn, assigns, relative_path, params) do
    if assigns[:current_project] do
      unverified_path(
        socket_or_conn,
        OrangeCmsWeb.Router,
        "/p/#{assigns.current_project.id}#{relative_path}",
        params
      )
    else
      relative_path
    end
  end
end
