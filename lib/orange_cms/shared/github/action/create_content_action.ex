defmodule OrangeCms.Shared.Github.CreateContentAction do
  alias OrangeCms.Shared.Github.Client
  alias OrangeCms.Shared.Github.Helper

  require Logger

  @committer %{
    "name" => "Orange Cms Admin",
    "email" => "sys@orangecms.io"
  }

  def perform(project, content_type, content_entry) do
    [owner, repo] = String.split(project.github_config["repo_name"], "/")

    # TODO remove hard-coded
    file_name =
      Calendar.strftime(DateTime.utc_now(), "%Y-%m-%d-") <>
        (Slugger.slugify_downcase(content_entry.title) |> String.slice(0, 50)) <> ".md"

    # TODO build from relative file name, subdir and contentdir
    path =
      Path.join(
        content_entry.content_type.github_config["content_dir"],
        file_name
        # content_entry.integration_info["relative_path"]
      )

    frontmatter = Helper.build_frontmatter_yaml(content_type, content_entry)

    content = """
    ---
    #{frontmatter}
    ---
    #{content_entry.raw_body}
    """

    body = %{
      "message" => "Create #{file_name}",
      "committer" => @committer,
      "content" => Base.encode64(content)
    }

    Client.api(
      project.github_config["access_token"],
      &Tentacat.Contents.create(&1, owner, repo, path, body)
    )
    |> case do
      {:ok, file} ->
        integration_info =
          content_entry.integration_info
          |> Map.from_struct()
          |> Map.merge(%{
            full_path: get_in(file, ["content", "path"]),
            name: get_in(file, ["content", "name"]),
            sha: get_in(file, ["content", "sha"])
          })

        OrangeCms.Content.update_content_entry(content_entry, %{
          integration_info: integration_info
        })

      {:error, error} = err ->
        Logger.error(inspect(error))
        err
    end
  end
end
