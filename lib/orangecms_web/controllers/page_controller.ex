defmodule OrangecmsWeb.PageController do
  use OrangecmsWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
