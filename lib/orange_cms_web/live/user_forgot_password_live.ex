defmodule OrangeCmsWeb.UserForgotPasswordLive do
  @moduledoc false
  use OrangeCmsWeb, :live_view

  alias OrangeCms.Accounts

  def render(assigns) do
    ~H"""
    <div class="bg-background flex h-screen w-full items-center">
      <div class="mx-auto max-w-sm">
        <.card>
          <.card_header class="text-center">
            <.card_title class="text-2xl">Forgot your password?</.card_title>
            <.card_description>We'll send a password reset link to your inbox</.card_description>
          </.card_header>

          <.card_content>
            <.simple_form for={@form} id="reset_password_form" phx-submit="send_email">
              <.input field={@form[:email]} type="email" placeholder="Email" required />
              <:actions>
                <.button phx-disable-with="Sending..." class="w-full">
                  Send password reset instructions
                </.button>
              </:actions>
            </.simple_form>
            <p class="mt-4 text-center text-sm">
              <!-- <.link href={~p"/register"}>Register</.link> | -->
              <.link href={~p"/log_in"}>Log in</.link>
            </p>
          </.card_content>
        </.card>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  def handle_event("send_email", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_reset_password_instructions(
        user,
        &url(~p"/users/reset_password/#{&1}")
      )
    end

    info = "If your email is in our system, you will receive instructions to reset your password shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
