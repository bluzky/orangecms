defmodule OrangeCms.Shared.Github do
  @moduledoc false
  alias OrangeCms.Shared.Github.Client

  require Logger

  def list_repository(token) do
    Client.list_repository(token)
  end

  defdelegate import_content(project, content_type),
    to: OrangeCms.Shared.Github.ImportContentAction,
    as: :perform

  defdelegate create_content(project, content_type, content_entry),
    to: OrangeCms.Shared.Github.CreateContentAction,
    as: :perform

  defdelegate update_content(project, content_type, content_entry),
    to: OrangeCms.Shared.Github.UpdateContentAction,
    as: :perform

  @doc """
  Publish content to github
  """
  def publish(project, content_type, content_entry) do
    if is_nil(content_entry.integration_info.full_path) do
      create_content(project, content_type, content_entry)
    else
      update_content(project, content_type, content_entry)
    end
  end

  defdelegate upload_file(project, content_type, upload),
    to: OrangeCms.Shared.Github.UploadFileAction,
    as: :perform
end
