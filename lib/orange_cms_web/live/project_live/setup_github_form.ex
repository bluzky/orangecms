defmodule OrangeCmsWeb.ProjectLive.GithubInfo do
  @moduledoc """
  Module for validate github repo config params
  """
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field(:access_token, :string)
    field(:repo_full_name, :string)
    field :repo_name, :string
    field :repo_owner, :string
  end

  def changeset(attrs \\ %{}) do
    %__MODULE__{}
    |> cast(attrs, [:access_token, :repo_full_name])
    |> validate_required([:access_token])
    |> validate_token()
    |> extract_detail()
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

  # extract repo_name and repo owner from repo_full_name
  defp extract_detail(changeset) do
    with true <- changeset.valid?,
         repo_full_name <- get_change(changeset, :repo_full_name) || "",
         [repo_owner, repo_name] <- String.split(repo_full_name, "/") do
      changeset
      |> put_change(:repo_owner, repo_owner)
      |> put_change(:repo_name, repo_name)
    else
      _ ->
        changeset
    end
  end
end

defmodule OrangeCmsWeb.ProjectLive.SetupGithubForm do
  @moduledoc false
  use OrangeCmsWeb, :live_component

  alias Ecto.Changeset
  alias OrangeCms.Projects
  alias OrangeCmsWeb.ProjectLive.GithubInfo

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
        phx-target={@myself}
      >
        <.form_item
          field={@form[:access_token]}
          label="Github access access token"
          description="You can obtain this access_token at Profile > Settings > Developer settings > Personal access tokens"
        >
          <.textarea field={@form[:access_token]} phx-debounce="blur" />
        </.form_item>

        <.form_item
          field={@form[:repo_full_name]}
          label="Repository"
          description="The repository where your content is stored"
        >
          <Input.input field={@form[:repo_full_name]} phx-debounce="blur" placeholder="owner/repo" />
        </.form_item>

        <div class="flex w-full flex-row-reverse">
          <.button icon_right="arrow-right" phx-disable-with="Checking...">
            Next
          </.button>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
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
  def handle_event("form_changed", %{"github_info" => params}, socket) do
    changeset =
      params
      |> GithubInfo.changeset()
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("submit", %{"github_info" => params}, socket) do
    changeset = GithubInfo.changeset(params)
    github_config = Changeset.apply_changes(changeset)

    with {:changeset, %{valid?: true}} <- {:changeset, changeset},
         {:load_repositories, {:ok, repositories}} <-
           {:load_repositories, OrangeCms.Shared.Github.list_repository(github_config.access_token)},
         {:validate_repo_name, %{}} <-
           {:validate_repo_name, Enum.find(repositories, &(&1["full_name"] == github_config.repo_full_name))},
         {:ok, project} <-
           Projects.update_project(socket.assigns.project, %{
             github_config: Map.from_struct(github_config),
             setup_completed: true
           }) do
      notify_parent({:saved, project})

      {:noreply, push_patch(socket, to: socket.assigns.patch)}
    else
      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}

      {:changeset, _} ->
        {:noreply, assign_form(socket, %{changeset | action: :validate})}

      {:load_repositories, _} ->
        changeset = Changeset.add_error(changeset, :access_token, "Invalid access access_token")
        {:noreply, assign_form(socket, %{changeset | action: :validate})}

      {:validate_repo_name, _} ->
        changeset = Changeset.add_error(changeset, :repo_full_name, "Repository does not exist")

        {:noreply, assign_form(socket, %{changeset | action: :validate})}
    end
  end

  defp assign_form(socket, params) do
    assign(socket, :form, to_form(params))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
