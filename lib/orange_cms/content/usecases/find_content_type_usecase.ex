defmodule OrangeCms.Content.FindContentTypeUsecase do
  @moduledoc """
  Find Content Type Usecase
  """
  use OrangeCms, :usecase

  alias OrangeCms.Content.ContentType

  @doc """
  Find Content Type
  """
  @spec call(map(), OrangeCms.Context.t()) :: ContentType.t()
  def call(filters, context) do
    filters = Map.put(filters, :project_id, context.project.id)
    OrangeCms.Content.ContentTypeQuery.find_content_type(filters)
  end
end
