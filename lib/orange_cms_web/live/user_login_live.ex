defmodule OrangeCmsWeb.UserLoginLive do
  @moduledoc false
  use OrangeCmsWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="bg-background flex h-screen w-full items-center">
      <div class="mx-auto max-w-sm">
        <.card>
          <.card_header class="text-center text-2xl">
            Sign in to account
          </.card_header>

          <.card_content>
            <.simple_form for={@form} id="login_form" action={~p"/log_in"} phx-update="ignore">
              <.input
                field={@form[:email]}
                type="email"
                label="Email"
                placeholder="myemail@example.com"
                required
              />
              <.input
                field={@form[:password]}
                type="password"
                label="Password"
                placeholder="password"
                required
              />

              <:actions>
                <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
                <.link href={~p"/users/reset_password"} class="text-sm font-semibold">
                  Forgot your password?
                </.link>
              </:actions>
              <:actions>
                <.button phx-disable-with="Signing in..." class="w-full">
                  Sign in <span aria-hidden="true">→</span>
                </.button>
              </:actions>
            </.simple_form>
            <!--<div class="mt-4 text-sm">
              Don't have an account? <.link
                navigate={~p"/register"}
                class="text-brand font-semibold hover:underline"
              >
          Sign up now
        </.link>.
            </div> -->
          </.card_content>
        </.card>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = live_flash(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
