defmodule OrangeCmsWeb.ProjectLive.GithubInfo do
  @moduledoc """
  Module for validate github repo config params
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field(:access_token, :string)
    field(:repo_name, :string)
  end

  def changeset(attrs \\ %{}) do
    %__MODULE__{}
    |> cast(attrs, [:access_token, :repo_name])
    |> validate_required([:access_token])
    |> validate_token()
  end

  defp validate_token(changeset) do
    case fetch_change(changeset, :access_token) do
      {:ok, access_token} ->
        if String.starts_with?(access_token, "github_pat_") do
          changeset
        else
          add_error(changeset, :access_token, "Invalid access access_token")
        end

      _ ->
        changeset
    end
  end
end

defmodule OrangeCmsWeb.ProjectLive.SetupGithubForm do
  @moduledoc false
  use OrangeCmsWeb, :live_component

  alias OrangeCms.Projects
  alias OrangeCmsWeb.ProjectLive.GithubInfo
  alias Ecto.Changeset

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form
        class="space-y-6"
        for={@form}
        id="setup_github"
        phx-change="form_changed"
        phx-submit="submit"
        id="github-import-form"
        phx-target={@myself}
      >
        <.form_item
          field={@form[:access_token]}
          label="Github access access token"
          description="You can obtain this access_token at Profile > Settings > Developer settings > Personal access tokens"
        >
          <.textarea
            field={@form[:access_token]}
            phx-debounce="blur"
          />
        </.form_item>

        <.form_item
          field={@form[:repo_name]}
          label="Repository"
          description="The repository where your content is stored"
        >
          <Input.input
            field={@form[:repo_name]}
            phx-debounce="blur"
            placeholder="owner/repo"
          />
        </.form_item>

        <div class="w-full flex flex-row-reverse">
          <.button
            icon_right="arrow-right"
            phx-disable-with="Checking..."
          >
            Next
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
       processing: false
     )
     |> assign_form(GithubInfo.changeset())}
  end

  @impl true
  def handle_event(
        "form_changed",
        %{"github_info" => params},
        socket
      ) do
    changeset =
      params
      |> GithubInfo.changeset()
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign_form(changeset)}
  end

  @impl true
  def handle_event("submit", %{"github_info" => params}, socket) do
    changeset = GithubInfo.changeset(params)

    with {:changeset, %{valid?: true}} <- {:changeset, changeset},
         access_token <- Changeset.get_field(changeset, :access_token),
         {:load_repositories, {:ok, repositories}} <-
           {:load_repositories, OrangeCms.Shared.Github.list_repository(access_token)},
         repo_name <- Changeset.get_field(changeset, :repo_name) |> IO.inspect(),
         {:validate_repo_name, %{}} <-
           {:validate_repo_name, Enum.find(repositories, &(&1["full_name"] == repo_name))},
         {:ok, project} <-
           Projects.update_project(socket.assigns.project, %{
             "github_config" => params,
             "setup_completed" => true
           }) do
      notify_parent({:saved, project})

      {:noreply, push_patch(socket, to: socket.assigns.patch)}
    else
      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}

      error ->
        changeset =
          case error do
            {:changeset, changeset} ->
              changeset

            {:load_repositories, _} ->
              Changeset.add_error(changeset, :access_token, "Invalid access access_token")

            {:validate_repo_name, _} ->
              Changeset.add_error(changeset, :repo_name, "Repository does not exist")
          end

        {:noreply, socket |> assign_form(%{changeset | action: :validate})}
    end
  end

  @impl true
  def handle_event(
        "form_changed",
        %{
          "_target" => ["content_dir"],
          "access_token" => access_token,
          "content_dir" => content_dir
        } = params,
        socket
      ) do
    %{repository: repository} = socket.assigns

    case OrangeCms.Shared.Github.Client.get_content(
           access_token,
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
