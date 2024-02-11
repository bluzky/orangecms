defmodule OrangeCms.Accounts.ListUsersUsecase do
  @moduledoc """
  List users usecase
  """
  alias OrangeCms.Accounts.ListUsersQuery

  @spec call(map) :: {:ok, list(User.t())} | {:error, term}
  def call(filters) do
    filters
    |> ListUsersQuery.run()
    |> handle_result()
  end

  defp handle_result(users) do
    {:ok, users}
  end
end
