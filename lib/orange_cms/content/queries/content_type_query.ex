defmodule OrangeCms.Content.ContentTypeQuery do
  @moduledoc """
  Content Type Query
  """
  use OrangeCms, :query

  @doc """
  List Content Type
  """
  def list_content_type(filters) do
    OrangeCms.Content.ContentType
    |> Filter.with_filters(filters)
    |> Repo.all()
  end

  def find_content_type(filters) do
    OrangeCms.Content.ContentType
    |> Filter.with_filters(filters)
    |> Repo.one()
  end
end
