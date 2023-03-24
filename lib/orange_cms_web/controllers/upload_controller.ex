defmodule OrangeCmsWeb.UploadController do
  use OrangeCmsWeb, :controller

  def upload_image(conn, %{"file" => file, "project_id" => project_id}) do
    case OrangeCms.Projects.Project.get(project_id) do
      {:ok, project} ->
        case OrangeCms.Shared.Github.upload_assets(file, project) do
          {:ok, data} ->
            json(conn, %{status: "ok", data: data})

          {:error, :file_duplicated} ->
            put_status(conn, 400)
            |> json(%{status: "bad_params", message: "file duplicated"})

          {:error, error} ->
            put_status(conn, 500)
            |> json(%{status: "internal_error"})
        end

      _ ->
        put_status(conn, :not_found)
        |> json(%{status: "not_found"})
    end
  end
end