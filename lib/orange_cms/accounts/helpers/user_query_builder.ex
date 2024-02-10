defmodule OrangeCms.Accounts.Helpers.UserQueryBuilder do
  @moduledoc """
  Helper module to build query for user
  """
  alias OrangeCms.Shared.Filter

  def base_query do
    OrangeCms.Accounts.User
  end

  @doc """
  Build user query from a map of condition
  """
  def build(query, filters) do
    Filter.with_filters(query, filters)
  end
end
