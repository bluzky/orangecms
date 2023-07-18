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

  @doc """
  Rebuild URL with new params and return final URL as string

  params accepts map or keyword list, atom keys will be converted to string and remove duplicated
  """
  def build_url(%URI{} = uri, params) do
    query =
      (uri.query || "")
      |> URI.decode_query()
      |> Map.merge(Map.new(params, fn {k, v} -> {to_string(k), v} end))
      |> URI.encode_query()

    URI.to_string(%{uri | query: query})
  end

  def build_url(url, params) when is_binary(url) do
    url
    |> URI.parse()
    |> build_url(params)
  end
end
