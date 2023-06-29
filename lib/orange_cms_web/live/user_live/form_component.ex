defmodule OrangeCmsWeb.UserLive.FormComponent do
  @moduledoc false
  use OrangeCmsWeb, :live_component

  alias OrangeCms.Accounts

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
    form = Accounts.change_user(user)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(form)}
  end

  @impl true
  def handle_event("validate", %{"form" => user_params}, socket) do
    form =
      socket.assigns.user
      |> Accounts.change_user(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, form)}
  end

  def handle_event("save", %{"form" => user_params}, socket) do
    case Accounts.create_user(user_params) do
      {:ok, entry} ->
        {:noreply,
         socket
         |> put_flash(:success, "User updated successfully")
         |> push_navigate(to: ~p"/users/#{entry}")}

      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
