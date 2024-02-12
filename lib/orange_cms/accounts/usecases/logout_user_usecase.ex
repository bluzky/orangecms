defmodule OrangeCms.Accounts.LogoutUserUsecase do
  @moduledoc """
  This module is responsible for logging out a user.
  """
  use OrangeCms, :usecase

  @doc """
  This function is responsible for logging out a user.
  It deletes the user's session token.
  """
  @spec call(String.t()) :: :ok
  def call(token) do
    OrangeCms.Accounts.DeleteUserTokenCommand.call(token, "session")
    :ok
  end
end
