defmodule OrangeCmsWeb.LiveUserAuth do
  @moduledoc """
  Helpers for authenticating users in liveviews
  """

  use OrangeCmsWeb, :verified_routes

  import Phoenix.Component

  def on_mount(:live_user_optional, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:cont, socket}
    else
      {:cont, assign(socket, :current_user, nil)}
    end
  end

  def on_mount(:live_user_required, _params, _session, socket) do
    if socket.assigns[:current_user] do
      Ash.set_actor(socket.assigns[:current_user])
      {:cont, socket}
    else
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/sign-in")}
    end
  end

  # TODO: Make this work
  def on_mount(:live_no_user, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/p")}
    else
      {:cont, assign(socket, :current_user, nil)}
    end
  end
end
