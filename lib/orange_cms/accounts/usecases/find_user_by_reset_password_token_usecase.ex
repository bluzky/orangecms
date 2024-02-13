defmodule OrangeCms.Accounts.FindUserByResetPasswordTokenUsecase do
  @moduledoc """
  This module is responsible for finding a user by reset password token.
  """
  alias OrangeCms.Accounts.User
  alias OrangeCms.Accounts.UserToken

  @spec call(String.t()) :: {:ok, User.t()} | {:error, :invalid_token}
  def call(token) do
    with {:ok, hashed_token} <- UserToken.from_email_token(token) do
      hashed_token
      |> OrangeCms.Accounts.FindUserByTokenQuery.run("reset_password")
      |> handle_result()
    end
  end

  defp handle_result(nil), do: {:error, :invalid_token}
  defp handle_result(user), do: {:ok, user}
end
