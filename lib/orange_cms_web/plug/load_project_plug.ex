defmodule OrangeCmsWeb.LoadProjectPlug do
  @moduledoc """
  Load project if project_id params presents
  """
  import Plug.Conn

  def init(options), do: options

  def call(%{params: %{"project_id" => project_id}} = conn, _opts) do
    case OrangeCms.Projects.Project.get(project_id) do
      {:ok, project} ->
        assign(conn, :current_project, project)

      _error ->
        assign(conn, :current_project, nil)
    end
  end

  def call(conn, _opts) do
    conn
  end
end
