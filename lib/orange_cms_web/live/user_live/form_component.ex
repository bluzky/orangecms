defmodule OrangeCmsWeb.UserLive.FormComponent do
  @moduledoc false
  use OrangeCmsWeb, :live_component

  alias OrangeCms.Accounts
  alias OrangeCmsWeb.Components.Input

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form
        class="space-y-4"
        for={@form}
        id="user-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.form_item field={@form[:first_name]} label="First name">
          <Input.input field={@form[:first_name]} type="text" />
        </.form_item>
        <.form_item field={@form[:last_name]} label="Last name">
          <Input.input field={@form[:last_name]} type="text" />
        </.form_item>
        <.form_item field={@form[:email]} label="Email">
          <Input.input field={@form[:email]} type="email" />
        </.form_item>
        <.form_item field={@form[:password]} label="Password">
          <Input.input field={@form[:password]} type="text" />
        </.form_item>
        <div class="w-full flex flex-row-reverse">
          <.button icon="inbox_arrow_down" phx-disable-with="Saving...">Save User</.button>
        </div>
      </.form>
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
  def handle_event("validate", %{"user" => user_params}, socket) do
    form =
      socket.assigns.user
      |> Accounts.change_user(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, form)}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    save_user(socket, socket.assigns.action, user_params)
  end

  defp save_user(socket, :edit, params) do
    case Accounts.update_user(socket.assigns.user, params) do
      {:ok, user} ->
        notify_parent({:saved, user})

        {:noreply,
         socket
         |> put_flash(:info, "User updated successfully")
         |> push_patch(to: ~p"/users")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_user(socket, :new, user_params) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        notify_parent({:saved, user})

        {:noreply,
         socket
         |> put_flash(:success, "User created successfully")
         |> push_navigate(to: ~p"/users")}

      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
