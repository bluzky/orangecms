defmodule OrangeCms.Shared.Github.UploadFileAction do
  @moduledoc """
  Upload file from plug.Upload to github repo
  """
  alias OrangeCms.Shared.Github.Client

  @committer %{
    "name" => "Orange Cms Admin",
    "email" => "sys@orangecms.io"
  }

  def perform(project, %{github_config: settings}, upload) do
    [owner, repo] = String.split(project.github_config["repo_name"], "/")
    {:ok, content} = File.read(upload.path)

    path =
      settings.upload_dir
      |> Path.join(upload.filename)
      |> String.trim_leading("/")

    body = %{
      "message" => "Upload #{upload.filename}",
      "committer" => @committer,
      "content" => Base.encode64(content)
    }

    # save new hash after commit
    project.github_config["access_token"]
    |> Client.api(&Tentacat.Contents.update(&1, owner, repo, path, body))
    |> case do
      {:ok, file} ->
        path = get_in(file, ["content", "path"])

        access_path =
          "/"
          |> Path.join(path)
          |> String.replace_leading(settings.upload_dir, "")
          |> then(&Path.join(settings.serve_at, &1))

        {:ok,
         %{
           original_path: path,
           access_path: access_path,
           url: get_in(file, ["content", "download_url"])
         }}

      {:error, :validation_failed} ->
        {:error, :file_duplicated}

      error ->
        error
    end
  end
end
