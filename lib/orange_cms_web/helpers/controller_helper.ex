defmodule OrangeCmsWeb.ControllerHelpers do
  @moduledoc """
  This module contains helper functions for controllers
  """

  def current_user(socket_or_conn) do
    socket_or_conn.assigns.current_user
  end

  def context(socket_or_conn) do
    socket_or_conn.assigns.context
  end
end
