defmodule OrangeCms.Shared.Github do
  require Logger
  @endpoint "https://api.github.com/"

  defp client(token) do
    Tentacat.Client.new(%{access_token: token}, @endpoint)
  end

  def list_repository(token) do
    token
    |> client
    |> Tentacat.Repositories.list_mine(type: "owner")
    |> case do
      {200, data, _} ->
        {:ok, data}

      error ->
        error
    end
  end

  def get_content(token, owner, repo, path) do
    token
    |> client
    |> Tentacat.Contents.find(owner, repo, path)
    |> case do
      {200, data, _} ->
        {:ok, data}

      {404, _, _} ->
        {:error, :not_found}

      {_, error, _} ->
        {:error, error}
    end
  end

  def test() do
    project = OrangeCms.Projects.Project.get!("VQA3h3HdL8")
    Ash.set_tenant(project.id)
    content_type = OrangeCms.Content.ContentType.get_by_key!("blog")

    import_content(project, content_type)
  end

  def import_content(project, content_type) do
    case import_directory(project, content_type, content_type.github_config["content_dir"]) do
      {:ok, frontmatters} ->
        schema = construct_frontmatter_schema(frontmatters)

        OrangeCms.Projects.Project.update!(project, %{set_up_completed: true})
        OrangeCms.Content.ContentType.update!(content_type, %{field_defs: schema})

      {:error, error} ->
        Logger.error(inspect(error))
    end
  end

  defp import_directory(project, content_type, directory) do
    [owner, repo] = String.split(project.github_config["repo_name"], "/")

    case get_content(project.github_config["access_token"], owner, repo, directory) do
      {:ok, files} ->
        {:ok, Enum.map(files, &import_file(project, content_type, &1))}

      {:error, error} ->
        Logger.error(inspect(error))
        {:error, error}
    end
  end

  defp import_file(project, content_type, file) do
    [owner, repo] = String.split(project.github_config["repo_name"], "/")

    case get_content(project.github_config["access_token"], owner, repo, file["path"]) do
      {:ok, %{"content" => content}} ->
        {frontmatter_str, content} =
          content
          |> Base.decode64!(ignore: :whitespace)
          |> String.split("---")
          |> case do
            ["", frontmatter, content] -> {frontmatter, content}
            [frontmatter, content] -> {frontmatter, content}
            [content | _] -> {"", content}
          end

        # read frontmatter in order
        :yamerl_app.set_param(:node_mods, [YamlElixir.Node.KeywordList])

        frontmatter =
          case YamlElixir.read_from_string(frontmatter_str, maps_as_keywords: true) do
            {:ok, data} -> data
            _ -> %{}
          end

        # insert content entry
        OrangeCms.Content.ContentEntry.create!(%{
          title: frontmatter[:title] || file["name"],
          raw_body: content,
          frontmatter: Enum.into(frontmatter, %{}),
          content_type_id: content_type.id,
          project_id: project.id
        })

        frontmatter

      {:error, error} ->
        Logger.error(inspect(error))
    end
  end

  defp construct_frontmatter_schema(frontmatters) do
    frontmatters
    |> Enum.reduce([], fn item, acc ->
      merge_frontmatter(acc, item)
    end)
    |> Enum.map(fn field ->
      if field.type == "checkbox" do
        Map.put(field, :options_str, Enum.join(field.options, ","))
      else
        field
      end
    end)
    |> Enum.reverse()
  end

  defp merge_frontmatter(schema, frontmatter) do
    Enum.reduce(frontmatter, schema, fn {key, value}, schema ->
      case Enum.find_index(schema, &(&1.key == key)) do
        nil ->
          [new_field(key, value) | schema]

        idx ->
          List.update_at(schema, idx, &update_field(&1, value))
      end
    end)
  end

  defp new_field(key, value) do
    %{
      name: Phoenix.Naming.humanize(key),
      key: key,
      type: typeof(value),
      options: if(typeof(value) == "checkbox", do: value, else: [])
    }
  end

  defp update_field(field, value) do
    if field.type == "checkbox" and is_list(value) do
      options = Enum.uniq(field.options ++ value)
      %{field | options: options}
    else
      field
    end
  end

  defp typeof(a) do
    cond do
      is_number(a) -> "number"
      is_boolean(a) -> "boolean"
      is_binary(a) -> "string"
      is_list(a) -> "checkbox"
      true -> "string"
    end
  end
end
