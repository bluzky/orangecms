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
    project = assigns[:current_project] || assigns[:project]

    if project do
      unverified_path(
        socket_or_conn,
        OrangeCmsWeb.Router,
        "/p/#{project.id}#{relative_path}",
        params
      )
    else
      relative_path
    end
  end

  def scoped_path_fn(socket_or_conn) do
    fn relative_path -> scoped_path(socket_or_conn, relative_path) end
  end
end
