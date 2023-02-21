defmodule OrangeCmsWeb.PageController do
  use OrangeCmsWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
