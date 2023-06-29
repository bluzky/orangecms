defmodule OrangeCmsWeb.UserLive.FormComponent do
  @moduledoc false
  use OrangeCmsWeb, :live_component

  alias OrangeCms.Accounts
  alias OrangeCms.Accounts.User

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage user records in your database.</:subtitle>
      </.header>

      <.simple_form
        :let={f}
        for={@form}
        id="user-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={f[:first_name]} type="text" label="First name" />
        <.input field={f[:last_name]} type="text" label="Last name" />
        <.input field={f[:email]} type="text" label="Email" />
        <.input field={f[:password]} type="text" label="Password" />
        <.input field={f[:avatar]} type="text" label="Avatar" />
        <:actions>
          <.button phx-disable-with="Saving...">Save User</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{user: user} = assigns, socket) do
    form =
      if user.id do
        AshPhoenix.Form.for_update(user, :update, api: Accounts)
      else
        AshPhoenix.Form.for_create(User, :create, api: Accounts)
      end

    {:ok,
     socket
     |> assign(assigns)
     |> assign(form: form)}
  end

  @impl true
  def handle_event("validate", %{"form" => user_params}, socket) do
    form =
      AshPhoenix.Form.validate(
        socket.assigns.form,
        user_params
      )

    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("save", %{"form" => user_params}, socket) do
    form =
      AshPhoenix.Form.validate(
        socket.assigns.form,
        user_params
      )

    case AshPhoenix.Form.submit(form) do
      {:ok, entry} ->
        {:noreply,
         socket
         |> put_flash(:success, "User updated successfully")
         |> push_navigate(to: ~p"/users/#{entry.id}")}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end
end
