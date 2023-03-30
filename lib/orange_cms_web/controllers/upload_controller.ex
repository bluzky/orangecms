defmodule OrangeCmsWeb.UploadController do
  use OrangeCmsWeb, :controller

  def upload_image(conn, %{
        "file" => file,
        "project_id" => project_id,
        "content_type_id" => type_id
      }) do
    Ash.set_tenant(project_id)

    case OrangeCms.Content.ContentType.get(type_id) do
      {:ok, content_type} ->
        content_type = OrangeCms.Content.load!(content_type, :project)

        case OrangeCms.Shared.Github.upload_file(content_type.project, content_type, file) do
          {:ok, data} ->
            json(conn, %{status: "ok", data: data})

          {:error, :file_duplicated} ->
            put_status(conn, 400)
            |> json(%{status: "bad_params", message: "file duplicated"})

          {:error, _error} ->
            put_status(conn, 500)
            |> json(%{status: "internal_error"})
        end

      _ ->
        put_status(conn, :not_found)
        |> json(%{status: "not_found"})
    end
  end
end
