defmodule OrangeCms.Shared.Github.UpdateContentAction do
  alias OrangeCms.Shared.Github.Client
  alias OrangeCms.Shared.Github.Helper

  require Logger

  @committer %{
    "name" => "Orange Cms Admin",
    "email" => "sys@orangecms.io"
  }

  def perform(project, content_type, content_entry) do
    [owner, repo] = String.split(project.github_config["repo_name"], "/")

    frontmatter = Helper.build_frontmatter_yaml(content_type, content_entry)

    content = """
    ---
    #{frontmatter}
    ---
    #{content_entry.raw_body}
    """

    body = %{
      "message" => "Update #{content_entry.integration_info.name}",
      "committer" => @committer,
      "content" => Base.encode64(content),
      "sha" => content_entry.integration_info.sha
    }

    # save new hash after commit
    Client.api(
      project.github_config["access_token"],
      &Tentacat.Contents.update(&1, owner, repo, content_entry.integration_info.full_path, body)
    )
    |> case do
      {:ok, file} ->
        integration_info =
          Map.merge(content_entry.integration_info, %{
            full_path: get_in(file, ["content", "path"]),
            name: get_in(file, ["content", "name"]),
            sha: get_in(file, ["content", "sha"])
          })

        OrangeCms.Content.ContentEntry.update(content_entry, %{integration_info: integration_info})

      {:error, error} = err ->
        Logger.error(inspect(error))
        err
    end
  end
end
