defmodule OrangeCms.Shared.Github.UploadFileAction do
  @moduledoc """
  Upload file from plug.Upload to github repo
  """
  alias OrangeCms.Shared.Github.Client

  @committer %{
    "name" => "Orange Cms Admin",
    "email" => "sys@orangecms.io"
  }

  def perform(project, content_type, upload) do
    [owner, repo] = String.split(project.github_config["repo_name"], "/")
    {:ok, content} = File.read(upload.path)

    path =
      Path.join(content_type.image_settings.upload_dir, upload.filename)
      |> String.trim_leading("/")

    body = %{
      "message" => "Upload #{upload.filename}",
      "committer" => @committer,
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
