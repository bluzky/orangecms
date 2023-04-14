defmodule OrangeCmsWeb.ProjectLive.Show do
  use OrangeCmsWeb, :live_view

  alias OrangeCms.Projects
  alias OrangeCms.Projects.Project

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket, project: nil, form: nil, repositories: nil, message: nil, ready_next: false)}
  end

  @impl true
  def handle_params(%{"project_id" => id}, _url, socket) do
    project = Project.get!(id)
    {:noreply, assign(socket, project: project)}
  end

  def apply_action(socket, :setup_github, params) do
    socket
    |> assign(:page_title, "Setup github")
    |> assign(:form, to_form(params))
  end

  def apply_action(socket, :fetch_content, _params) do
    socket
    |> assign(:page_title, "Fetch Users")
  end

  @impl true
  def handle_event("form_changed", %{"_target" => ["token"], "token" => token} = params, socket) do
    if String.starts_with?(token, "github_pat_") do
      {:ok, repositories} = OrangeCms.Shared.Github.list_repository(token)

      form = to_form(params)

      {:noreply,
       socket
       |> reset_assigns
       |> assign(form: form, repositories: repositories)}
    else
      form =
        to_form(params,
          errors: [token: {"Invalid github personal access token", []}]
        )

      {:noreply, socket |> reset_assigns |> assign(:form, form)}
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
    # update config
    current_project =
      socket.assigns.current_project
      |> Ash.Changeset.for_update(:update, %{
        github_config: %{
          "access_token" => params["token"],
          "repo_name" => socket.assigns.repository["full_name"]
        }
      })
      |> Projects.update!()

    # create content type
    content_type_key = params["content_dir"] |> String.split("/") |> List.last()

    {:ok, content_type} =
      OrangeCms.Content.ContentType.create(%{
        project_id: current_project.id,
        name: Phoenix.Naming.humanize(content_type_key),
        key: content_type_key,
        github_config: %{"content_dir" => params["content_dir"]}
      })

    # import content
    OrangeCms.Shared.Github.import_content(current_project, content_type)

    {:noreply,
     assign(socket, current_project: current_project, content_type: content_type)
     |> push_navigate(to: scoped_path(socket, "/"))}
  end

  defp reset_assigns(socket) do
    assign(socket, repositories: nil, message: nil, ready_next: false, repository: nil)
  end
end
