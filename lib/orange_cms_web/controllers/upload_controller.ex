defmodule OrangeCmsWeb.UploadController do
  use OrangeCmsWeb, :controller

  def upload_image(conn, %{"file" => file, "project_id" => project_id, "content_type_id" => type_id}) do
    Ash.set_tenant(project_id)

    content_type =
      type_id
      |> OrangeCms.Content.get_content_type!()
      |> OrangeCms.Repo.preload(:project)

    case OrangeCms.Shared.Github.upload_file(content_type.project, content_type, file) do
      {:ok, data} ->
        json(conn, %{status: "ok", data: data})

      {:error, :file_duplicated} ->
        conn
        |> put_status(400)
        |> json(%{status: "bad_params", message: "file duplicated"})

      {:error, _error} ->
        conn
        |> put_status(500)
        |> json(%{status: "internal_error"})
    end
  end
end
