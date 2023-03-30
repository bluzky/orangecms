defmodule OrangeCms.Shared.Github.UploadFileAction do
  alias OrangeCms.Shared.Github.Client

  def perform(project, _content_type, upload) do
    [owner, repo] = String.split(project.github_config["repo_name"], "/")

    # TODO: read from config
    path = "public/assets/" <> upload.filename

    # TODO: handle error
    {:ok, content} = File.read(upload.path)

    body = %{
      "message" => "upload #{upload.filename}",
      "committer" => %{
        "name" => "Orange Cms Admin",
        "email" => "sys@orangecms.io"
      },
      "content" => Base.encode64(content)
    }

    # save new hash after commit
    Client.api(
      project.github_config["access_token"],
      &Tentacat.Contents.update(&1, owner, repo, path, body)
    )
    |> case do
      {:ok, file} ->
        {:ok,
         %{
           path: get_in(file, ["content", "path"]),
           url: get_in(file, ["content", "download_url"])
         }}

      {:error, :validation_failed} ->
        {:error, :file_duplicated}

      error ->
        error
    end
  end
end
