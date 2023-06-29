defmodule OrangeCmsWeb.LoadProjectPlug do
  @moduledoc """
  Load project if project_id params presents
  """
  import Plug.Conn

  def init(options), do: options

  def call(%{params: %{"project_id" => project_id}} = conn, _opts) do
    project = OrangeCms.Projects.get_project!(project_id)
    assign(conn, :current_project, project)
  end

  def call(conn, _opts) do
    conn
  end
end
