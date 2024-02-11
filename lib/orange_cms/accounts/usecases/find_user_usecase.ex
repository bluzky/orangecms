defmodule OrangeCms.Accounts.FindUserUsecase do
  @moduledoc """
  Find user usecase
  """
  alias OrangeCms.Accounts.FindUserQuery

  @spec call(map) :: {:ok, User.t()} | {:error, term}
  def call(filters) do
    filters
    |> FindUserQuery.run()
    |> handle_result()
  end

  defp handle_result(nil) do
    {:error, :not_found}
  end

  defp handle_result(user) do
    {:ok, user}
  end
end
