defmodule OrangeCms.Accounts.FindUserQuery do
  @moduledoc """
  Find user query
  """
  use OrangeCms, :query

  alias OrangeCms.Accounts.Helpers.UserQueryBuilder
  alias OrangeCms.Accounts.User

  @spec run(map) :: {:ok, User.t()} | {:error, term}
  def run(filters) do
    UserQueryBuilder.base_query()
    |> build_query(filters)
    |> limit(1)
    |> Repo.one()
  end

  defp build_query(query, filters) do
    Filter.with_filters(query, filters)
  end
end
