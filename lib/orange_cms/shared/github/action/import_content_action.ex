defmodule OrangeCms.Shared.Github.ImportContentAction do
  @moduledoc """
  Import markdonw file from github directory as follow:

  1. Create content type if not exist
  2. List all markdown file
  3. For each file
    3.1 Get file content, info
    3.2 [TODO] If content exist -> update
    3.3 Else -> create

  4. Collect all frontmatter and build frontmatter schema
  5. Update content type frontmatter schema
  """

  alias OrangeCms.Shared.Github.Client
  alias OrangeCms.Shared.Github.Helper

  require Logger

  def perform(project, content_type) do
    case import_directory(project, content_type, content_type.github_config.content_dir) do
      {:ok, frontmatters} ->
        schema = construct_frontmatter_schema(frontmatters)
        # TODO: transaction
        OrangeCms.Projects.update_project(project, %{setup_completed: true})
        OrangeCms.Content.update_content_type(content_type, %{frontmatter_schema: schema})

      {:error, error} ->
        Logger.error(inspect(error))
    end
  end

  # Import all markdown files within a directory
  defp import_directory(project, content_type, directory) do
    %{github_config: gh_config} = project

    case Client.api(
           gh_config.access_token,
           &Tentacat.Contents.find(&1, gh_config.repo_owner, gh_config.repo_name, directory)
         ) do
      {:ok, files} ->
        # import all markdown file only
        {:ok,
         files
         |> Enum.reject(&(not String.ends_with?(&1["path"], ".md")))
         |> Enum.map(&import_file(project, content_type, &1))}

      {:error, error} ->
        Logger.error(inspect(error))
        {:error, error}
    end
  end

  # Request file content from github
  # Parse file content
  # insert file to database
  defp import_file(project, content_type, file) do
    %{github_config: gh_config} = project

    case Client.api(
           gh_config.access_token,
           &Tentacat.Contents.find(&1, gh_config.repo_owner, gh_config.repo_name, file["path"])
         ) do
      {:ok, %{"content" => content} = file} ->
        {frontmatter, content} = Helper.parse_markdown_content(content)

        title =
          Enum.find_value(frontmatter, file["name"], fn {k, v} ->
            if k == "title", do: v
          end)

        # insert content entry
        OrangeCms.Content.create_content_entry(%{
          title: title,
          body: content,
          frontmatter: Map.new(frontmatter),
          content_type_id: content_type.id,
          project_id: project.id,
          integration_info: %{
            name: file["name"],
            full_path: file["path"],
            relative_path:
              file["path"]
              |> String.replace_prefix(content_type.github_config.content_dir, "")
              |> String.replace_prefix("/", ""),
            sha: file["sha"]
          }
        })

        frontmatter

      {:error, error} ->
        Logger.error(inspect(error))
    end
  end

  # Build frontmatter schema from all contents' frontmatter
  defp construct_frontmatter_schema(frontmatters) do
    frontmatters
    |> Enum.reduce([], fn item, acc ->
      merge_frontmatter(acc, item)
    end)
    |> Enum.map(fn field ->
      # if type is checkbox (list), then concat all options into a single string
      if field.type == "checkbox" do
        Map.put(field, :options_str, Enum.join(field.options, ","))
      else
        field
      end
    end)
    |> Enum.reverse()
  end

  # Merge fronmatter
  # If field does not exist -> create new field and append to schema
  # If field does exist -> merge/update field if it's field with options
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

  # construct new field
  defp new_field(key, value) do
    %{
      name: Phoenix.Naming.humanize(key),
      key: key,
      type: typeof(value),
      options: if(typeof(value) == "checkbox", do: value, else: [])
    }
  end

  # update field options
  defp update_field(field, value) do
    if field.type == "checkbox" and is_list(value) do
      options = Enum.uniq(field.options ++ value)
      %{field | options: options}
    else
      field
    end
  end

  # determine field type base on value type
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
