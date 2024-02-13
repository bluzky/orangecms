defmodule OrangeCms.Accounts.ConfirmUserUsecase do
  @moduledoc """
  This module is responsible for confirming a user.

  1. Build token from email token
  2. Find user by token
  3. Confirm user account & remove token
  """

  use OrangeCms, :usecase

  alias OrangeCms.Accounts.FindUserByTokenQuery
  alias OrangeCms.Accounts.User
  alias OrangeCms.Accounts.UserToken

  @doc """
  This function is responsible for confirming a user.
  It deletes the user's confirmation token and sets the user's status to "confirmed".
  """
  @spec call(String.t()) :: {:ok, User.t()} | {:error, term()}
  def call(token) do
    with {:ok, hashed_token} <- UserToken.from_email_token(token),
         {:ok, user} <- find_user_by_token(hashed_token) do
      user
      |> OrangeCms.Accounts.ConfirmUserCommand.call()
      |> handle_result()
    end
  end

  defp find_user_by_token(hashed_token) do
    hashed_token
    |> FindUserByTokenQuery.run("confirm")
    |> case do
      nil -> {:error, :invalid_token}
      user -> {:ok, user}
    end
  end

  def handle_result({:ok, user}), do: {:ok, user}
  def handle_result({:error, error}), do: {:error, error}
end
