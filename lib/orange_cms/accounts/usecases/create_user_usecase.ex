defmodule OrangeCms.Accounts.CreateUserUsecase do
  @moduledoc """
  Create user usecase
  """
  alias OrangeCms.Accounts.CreateUserCommand

  @spec call(map) :: {:ok, User.t()} | {:error, term}
  def call(attrs) do
    attrs
    |> CreateUserCommand.call()
    |> handle_result()
  end

  defp handle_result({:ok, user}) do
    {:ok, user}
  end

  defp handle_result({:error, reason}) do
    {:error, reason}
  end
end
