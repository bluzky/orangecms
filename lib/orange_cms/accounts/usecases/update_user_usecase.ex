defmodule OrangeCms.Accounts.UpdateUserUsecase do
  @moduledoc """
  Update user usecase
  """
  alias OrangeCms.Accounts.UpdateUserCommand
  alias OrangeCms.Accounts.User

  @spec call(User.t(), map) :: {:ok, User.t()} | {:error, term}
  def call(user, params) do
    user
    |> UpdateUserCommand.call(params)
    |> handle_result()
  end

  defp handle_result({:ok, user}) do
    {:ok, user}
  end

  defp handle_result({:error, reason}) do
    {:error, reason}
  end
end
