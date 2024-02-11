defmodule OrangeCms.Accounts.RegisterUserUsecase do
  @moduledoc """
  Register user usecase
  """
  alias OrangeCms.Accounts.RegisterUserCommand
  alias OrangeCms.Accounts.User

  @spec call(map) :: {:ok, User.t()} | {:error, term}
  def call(attrs) do
    attrs
    |> RegisterUserCommand.call()
    |> handle_result()
  end

  defp handle_result({:ok, user}) do
    {:ok, user}
  end

  defp handle_result({:error, reason}) do
    {:error, reason}
  end
end
