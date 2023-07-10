defmodule OrangeCmsWeb.ProjectLive.GithubImportContentForm do
  @moduledoc false
  use OrangeCmsWeb, :live_component

  alias Ecto.Changeset
  alias OrangeCms.Content
  alias OrangeCms.Content.ContentType

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div :if={@step == :select_content_dir}>
        <.form
          class="space-y-6"
          for={@form}
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
            <.form_message field={@form[:key]} />
          </.form_item>

          <div class="w-full flex flex-row-reverse">
            <.button icon_right="arrow-right" phx-disable-with="Fetching content...">
              Next
            </.button>
          </div>
        </.form>
      </div>

      <div :if={@step == :import_content && @import_status == :pending} class="space-y-6">
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

      <div :if={@step == :import_content && @import_status == :processing} class="space-y-6">
        <div class="flex justify-center">
          <Heroicons.sun class="h-20 w-22 animate-spin" />
        </div>
        <p class="text-center text-lg text-muted-foreground">
          Importing content...
        </p>
      </div>

      <div :if={@step == :import_content && @import_status == :done} class="space-y-6">
        <% {kind, msg} = @message %>
        <.alert kind={kind}>
          <%= msg %>
        </.alert>
        <div class="w-full flex justify-center">
          <.link navigate={scoped_path(assigns, "/content/#{@content_type.key}")}>
            <.button phx-click="back" phx-target={@myself}>
              Close
            </.button>
          </.link>
        </div>
      </div>
    </div>
    """
  end

  # @steps [:select_content_dir, :import_content]
  # @import_statuses [:pending, :processing, :done]

  @impl true
  def mount(socket) do
    {:ok, assign(socket, step: :select_content_dir, files: [], import_status: :pending)}
  end

  @impl true
  def update(assigns, socket) do
    project = assigns[:project] || socket.assigns[:project]
    changeset = Content.change_content_type(%ContentType{}, %{project_id: project.id})

    {:ok,
     socket
     |> assign(assigns)
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

  # Move back to select content directory step
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
  def handle_event("import_content", _params, %{assigns: assigns} = socket) do
    {:ok, content_type} = OrangeCms.Content.create_content_type(assigns.project, assigns.content_type_params)

    socket = assign(socket, content_type: content_type, import_status: :processing)

    Task.start(fn ->
      # import content
      OrangeCms.Shared.Github.import_content(assigns.project, content_type)

      send_update(
        OrangeCmsWeb.ProjectLive.GithubImportContentForm,
        %{
          id: assigns.project.id,
          import_status: :done,
          message: {:success, "Content import completed"}
        }
      )

      :ok
    end)

    {:noreply, socket}
  end

  @doc """
  Show results of the content import
  """
  def handle_info(ref, socket) do
    Process.demonitor(ref, [:flush])
    # %{predictions: [%{label: label}]} = result
    {:noreply, assign(socket, import_status: :done)}
  end

  defp assign_form(socket, params) do
    assign(socket, :form, to_form(params))
  end
end
