defmodule OrangeCmsWeb.ProjectUserLive.FormComponent do
  @moduledoc false
  use OrangeCmsWeb, :live_component

  alias OrangeCms.Accounts
  alias OrangeCms.Projects

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.simple_form for={@form} id="user-form" phx-target={@myself} phx-submit="save">
        <div class="hidden">
          <.input
            field={@form[:user_id]}
            value={(@selected_item && @selected_item.value) || nil}
            type="text"
            label="User"
          />
        </div>

        <div class="relative w-full">
          <div
            class={[
              "dropdown w-full group",
              @search && "dropdown-open",
              not is_nil(@project_user.id) && "disabled"
            ]}
            phx-click-away="hide-search-box"
            phx-target={@myself}
          >
            <label
              tabindex="0"
              class="flex gap-2 items-center w-full h-12 p-2 px-4 rounded-lg border border-base-300"
              phx-click="toggle-search-box"
              phx-target={@myself}
            >
              <%= if @selected_item, do: @selected_item.label, else: "select a user" %>
              <.icon name="chevron-down" class="w-5 h-5 ml-auto group-focus-within:rotate-180" />
            </label>
            <ul
              tabindex="0"
              class={[
                "dropdown-content menu flex-row shadow bg-base-100 rounded-box w-full overflow-y-auto",
                (not @search || not is_nil(@project_user.id)) && "hidden"
              ]}
              style="max-height: 330px"
            >
              <li class="w-full">
                <div class="form-control">
                  <input
                    type="text"
                    class="input input-bordered w-full"
                    phx-change="search_user"
                    phx-debounce="300"
                    name="search_str"
                    placeholder="search user by email"
                  />
                </div>
              </li>
              <%= if not Enum.empty?(@suggestions) do %>
                <li
                  :for={item <- @suggestions}
                  class="w-full"
                  phx-value-selected={item.value}
                  phx-click="select-item"
                  phx-target={@myself}
                >
                  <a><%= item.label %></a>
                </li>
              <% end %>
            </ul>
          </div>
          <label :if={@error} class="text-error text-sm flex gap-1 py-2">
            <.icon name="exclamation-circle" /> <%= @error %>
          </label>
        </div>

        <.input type="select" field={@form[:role]} options={OrangeCms.Projects.MemberRole.values()} />
        <:actions>
          <.button class="btn-md btn-secondary" phx-disable-with="Saving...">
            <.icon name="inbox" /> Save Member
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{project_user: project_user} = assigns, socket) do
    changeset = Projects.change_project_user(project_user)

    {:ok,
     socket
     |> assign_form(changeset)
     |> assign(assigns)
     |> assign(
       suggestions: [],
       selected_item: nil,
       search: false,
       error: nil
     )}
  end

  @impl true
  def handle_event("toggle-search-box", _params, socket) do
    {:noreply, assign(socket, search: not socket.assigns.search)}
  end

  @impl true
  def handle_event("hide-search-box", _params, socket) do
    {:noreply, assign(socket, search: false)}
  end

  @impl true
  def handle_event("search_user", %{"search_str" => search_str}, socket) do
    if String.trim(search_str) != "" do
      users = Accounts.search_user(search_str)

      {:noreply,
       assign(socket,
         suggestions:
           Enum.map(
             users,
             &%{value: &1.id, label: "#{&1.first_name} #{&1.last_name} <#{&1.email}>"}
           )
       )}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("select-item", %{"selected" => value}, socket) do
    selected_item = Enum.find(socket.assigns.suggestions, &(to_string(&1.value) == value))

    if selected_item do
      {:noreply,
       assign(socket,
         search: false,
         selected_item: selected_item
       )}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("validate", %{"project_user" => project_user_params}, socket) do
    changeset =
      socket.assigns.project
      |> Projects.change_project_user(project_user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"project_user" => params}, socket) do
    save_project(socket, socket.assigns.action, params)
  end

  defp save_project(socket, :edit, params) do
    case Projects.update_project_user(socket.assigns.project_user, params) do
      {:ok, project_user} ->
        notify_parent({:saved, project_user})

        {:noreply,
         socket
         |> put_flash(:info, "Member updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_project(socket, :new, params) do
    params =
      Map.merge(params, %{
        "project_id" => socket.assigns.current_project.id
      })

    case Projects.create_project_user(params) do
      {:ok, project_user} ->
        notify_parent({:saved, project_user})

        {:noreply,
         socket
         |> assign(error: nil)
         |> put_flash(:info, "Member added successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
