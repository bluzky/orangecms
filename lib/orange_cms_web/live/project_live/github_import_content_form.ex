defmodule OrangeCmsWeb.ProjectLive.GithubImportContentForm do
  @moduledoc false
  use OrangeCmsWeb, :live_component

  alias Ecto.Changeset
  alias OrangeCms.Content
  alias OrangeCms.Content.ContentType
  alias OrangeCms.Projects

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div :if={@step == :select_content_dir}>
        <.form
          class="space-y-6"
          for={@form}
          id="setup_github"
          phx-change="validate"
          phx-submit="check_content"
          id="github-import-form"
          phx-target={@myself}
        >
          <.inputs_for :let={f} field={@form[:github_config]}>
            <.form_item
              field={f[:content_dir]}
              label="Content directory"
              description="The directory where your markdown files are stored"
            >
              <Input.input
                field={f[:content_dir]}
                phx-debounce="blur"
                placeholder="e.g. src/content/blog"
              />
            </.form_item>
          </.inputs_for>

          <.form_item field={@form[:name]} label="Content collection name">
            <Input.input field={@form[:name]} placeholder="e.g. blog" />
          </.form_item>

          <div class="w-full flex flex-row-reverse">
            <.button icon_right="arrow-right" phx-disable-with="Fetching content...">
              Next
            </.button>
          </div>
        </.form>
      </div>

      <div :if={@step == :import_content} class="space-y-6">
        <% {kind, msg} = @message %>
        <.alert kind={kind}>
          <%= msg %>
        </.alert>

        <.scroll_area :if={not Enum.empty?(@files)} class="h-72 w-full rounded-md border">
          <div class="p-4">
            <%= for file <- @files do %>
              <div class="text-sm">
                <%= file %>
              </div>
              <.separator class="my-2" />
            <% end %>
          </div>
        </.scroll_area>
        <div class="w-full flex justify-between">
          <.button icon="arrow-left" phx-click="back" phx-target={@myself} variant="secondary">
            Back
          </.button>

          <.button icon="inbox-arrow-down" phx-click="import_content" phx-target={@myself}>
            Import content
          </.button>
        </div>
      </div>
    </div>
    """
  end

  @steps [:select_content_dir, :import_content]

  @impl true
  def update(%{project: project} = assigns, socket) do
    changeset = Content.change_content_type(%ContentType{}, %{project_id: project.id})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(processing: false, step: :select_content_dir, files: [])
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"content_type" => params}, socket) do
    changeset =
      %ContentType{project_id: socket.assigns.project.id}
      |> Content.change_content_type(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  @doc """
  Check if the content directory exists and contains markdown files
  """
  def handle_event("check_content", %{"content_type" => params}, socket) do
    %{project: project} = socket.assigns

    changeset = Content.change_content_type(%ContentType{project_id: socket.assigns.project.id}, params)

    with %{valid?: true} <- changeset,
         content_type <- Changeset.apply_changes(changeset),
         {:ok, files} <-
           OrangeCms.Shared.Github.Client.get_content(
             project.github_config,
             content_type.github_config.content_dir
           ) do
      md_files =
        files
        |> Enum.filter(&(String.ends_with?(&1["name"], ".md") and &1["type"] == "file"))
        |> Enum.map(& &1["name"])

      if length(md_files) > 0 do
        {:noreply,
         socket
         |> assign(step: :import_content, can_continue: true, content_type_params: params)
         |> assign(files: md_files)
         |> assign(message: {:success, "Found #{length(md_files)} markdown files"})
         |> assign_form(changeset)}
      else
        {:noreply,
         socket
         |> assign(step: :import_content, can_continue: false, content_type_params: params)
         |> assign(message: {:error, "No markdown file found. Please select another directory"})
         |> assign_form(changeset)}
      end
    else
      {:error, :not_found} ->
        changeset =
          Changeset.update_change(changeset, :github_config, fn changeset ->
            Changeset.add_error(changeset, :content_dir, "directory does not exist")
          end)

        changeset = Map.put(changeset, :action, :validate)
        {:noreply, assign_form(socket, changeset)}

      _ ->
        changeset = Map.put(changeset, :action, :validate)
        {:noreply, assign_form(socket, changeset)}
    end
  end

  @doc """
  Move back to select content directory step
  """
  @impl true
  def handle_event("back", _params, socket) do
    project = socket.assigns.project

    changeset =
      Content.change_content_type(%ContentType{project_id: project.id}, socket.assigns.content_type_params || %{})

    {:noreply,
     socket
     |> assign(step: :select_content_dir, content_type_params: nil)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("import_content", params, socket) do
    # TODO handle update error
    {:ok, current_project} =
      Projects.update_project(socket.assigns.current_project, %{
        github_config: %{
          "access_token" => params["access_token"],
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

  defp assign_form(socket, params) do
    assign(socket, :form, to_form(params))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
