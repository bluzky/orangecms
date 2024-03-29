defmodule OrangeCmsWeb.PreviewController do
  use OrangeCmsWeb, :controller

  def preview(conn, %{"path" => path, "project_id" => _project_id, "content_type_id" => type_id}) do
    content_type =
      type_id
      |> OrangeCms.Content.get_content_type!()
      |> OrangeCms.Repo.preload(:project)

    url =
      cond do
        String.starts_with?(path, "https://") or String.starts_with?(path, "http://") ->
          path

        true ->
          path =
            String.replace_leading(
              path,
              (content_type && content_type.github_config.serve_at) || "",
              content_type.github_config.upload_dir || ""
            )

          Path.join([
            "https://raw.githubusercontent.com/",
            content_type.project.github_config["repo_name"],
            "/main",
            path
          ])
      end

    redirect(conn, external: url)
  end
end
