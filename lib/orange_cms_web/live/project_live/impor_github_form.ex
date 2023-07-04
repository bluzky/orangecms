defmodule OrangeCmsWeb.ProjectLive.ImportGithubForm do
  @moduledoc false
  use OrangeCmsWeb, :live_component

  alias OrangeCms.Projects

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form
        class="space-y-6"
        for={@form}
        id="setup_github"
        phx-change="form_changed"
        phx-submit="import_content"
        id="github-import-form"
        phx-target={@myself}
      >
        <.form_item
          field={@form[:name]}
          label="Github access token"
          description="You can obtain this token at Profile > Settings > Developer settings > Personal access tokens"
        >
          <Input.input
            field={@form[:token]}
            phx-debounce="500"
            label="Paste your personal github token here"
          />
        </.form_item>

        <.form_item field={@form[:repository]} label="Select your desired repo">
          <.select field={@form[:repository]} class="w-full">
            <.select_trigger {%{disabled: Enum.empty?(@repositories || [])}}>
              <.select_value placeholder="Select repository" />
            </.select_trigger>
            <.select_content>
              <.select_group>
                <.select_item
                  :for={item <- @repositories || []}
                  field={@form[:repository]}
                  value={item["full_name"]}
                >
                  <%= item["full_name"] %>
                </.select_item>
              </.select_group>
            </.select_content>
          </.select>
        </.form_item>

        <.form_item
          field={@form[:name]}
          label="Path to content directory"
          description="Relative to repository root"
        >
          <Input.input
            field={@form[:content_dir]}
            phx-debounce="blur"
            {%{disabled: Enum.empty?(@repositories ||[])}}
          />
        </.form_item>

        <%= if @message do %>
          <% {kind, content} = @message %>
          <.alert kind={kind}>
            <%= content %>
          </.alert>
        <% end %>

        <div class="w-full flex flex-row-reverse">
          <.button
            icon="inbox_arrow_down"
            {%{disabled: (not @ready_next)}}
            phx-disable-with="Saving..."
          >
            Save project
          </.button>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def update(%{project: project} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(
       form: nil,
       repositories: [],
       message: nil,
       ready_next: false
     )
     |> assign_form(%{"token" => nil, "repository" => nil, "content_dir" => nil})}
  end

  @impl true
  def handle_event("form_changed", %{"_target" => ["token"], "token" => token} = params, socket) do
    if String.starts_with?(token, "github_pat_") do
      {:ok, repositories} = OrangeCms.Shared.Github.list_repository(token)

      repositories = Enum.filter(repositories, & &1["permissions"]["push"])

      form = to_form(params)

      {:noreply,
       socket
       |> reset_assigns()
       |> assign(form: form, repositories: repositories)}
    else
      form =
        to_form(params,
          errors: [token: {"Invalid github personal access token", []}]
        )

      {:noreply, socket |> reset_assigns() |> assign(:form, form)}
    end
  end

  @impl true
  def handle_event(
        "form_changed",
        %{"_target" => ["repository"], "repository" => repo_name} = params,
        socket
      ) do
    repository = Enum.find(socket.assigns.repositories, &(&1["full_name"] == repo_name))

    {:noreply,
     assign(socket,
       repository: repository,
       form: to_form(params),
       content_dir: nil,
       ready_next: false
     )}
  end

  @impl true
  def handle_event(
        "form_changed",
        %{"_target" => ["content_dir"], "token" => token, "content_dir" => content_dir} = params,
        socket
      ) do
    %{repository: repository} = socket.assigns

    case OrangeCms.Shared.Github.Client.get_content(
           token,
           repository["owner"]["login"],
           repository["name"],
           content_dir
         ) do
      {:ok, files} ->
        md_files =
          Enum.filter(files, &(String.ends_with?(&1["name"], ".md") and &1["type"] == "file"))
          |> IO.inspect()

        if length(md_files) > 0 do
          {:noreply,
           assign(socket,
             form: to_form(params),
             message: {:success, "Found #{length(md_files)} markdown files"},
             ready_next: true
           )}
        else
          {:noreply,
           assign(socket,
             form: to_form(params),
             message: {:error, "No markdown file found. Please select another directory"},
             ready_next: false
           )}
        end

      {:error, :not_found} ->
        {:noreply,
         assign(socket,
           form: to_form(params, errors: [content_dir: {"directory does not exist", []}]),
           ready_next: false
         )}
    end
  end

  @impl true
  def handle_event("form_changed", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("import_content", params, socket) do
    # TODO handle update error
    {:ok, current_project} =
      Projects.update_project(socket.assigns.current_project, %{
        github_config: %{
          "access_token" => params["token"],
          "repo_name" => socket.assigns.repository["full_name"]
        }
      })

    # create content type
    content_type_key = params["content_dir"] |> String.split("/") |> List.last()

    {:ok, content_type} =
      OrangeCms.Content.create_content_type(%{
        project_id: current_project.id,
        name: Phoenix.Naming.humanize(content_type_key),
        key: content_type_key,
        github_config: %{"content_dir" => params["content_dir"]}
      })

    # import content
    OrangeCms.Shared.Github.import_content(current_project, content_type)

    {:noreply,
     socket
     |> assign(current_project: current_project, content_type: content_type)
     |> push_navigate(to: scoped_path(socket, "/"))}
  end

  defp reset_assigns(socket) do
    assign(socket, repositories: nil, message: nil, ready_next: false, repository: nil)
  end

  defp assign_form(socket, params) do
    assign(socket, :form, to_form(params))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
