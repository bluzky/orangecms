defmodule OrangeCms.Content.ListContentTypeUsecase do
  @moduledoc """
  List Content Type Usecase
  """
  use OrangeCms, :usecase

  alias OrangeCms.Content.ContentType

  @doc """
  List Content Type
  """
  @spec call(map, OrangeCms.Context.t()) :: list(ContentType.t())
  def call(filters, context) do
    filters = Map.put(filters, :project_id, context.project.id)
    OrangeCms.Content.ContentTypeQuery.list_content_type(filters)
  end
end
