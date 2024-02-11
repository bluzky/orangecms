defmodule OrangeCms.Accounts.ListUsersQuery do
  @moduledoc """
  List users query
  """
  use OrangeCms, :query

  alias OrangeCms.Accounts.User

  @spec run(map) :: list(User.t())
  def run(filters) do
    User
    |> build_query(filters)
    |> order_by([u], u.first_name)
    |> Repo.all()
  end

  defp build_query(query, filters) do
    Filter.with_filters(query, filters)
  end
end
