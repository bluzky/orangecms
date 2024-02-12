defmodule OrangeCms.Accounts.LogInUserUsecase do
  @moduledoc """
  This module is responsible for logging in a user.
  """
  use OrangeCms, :usecase

  alias OrangeCms.Accounts.User
  alias OrangeCms.Accounts.UserToken

  @doc """
  This function is responsible for logging in a user.
  It creates a session token and returns it.
  """
  @spec call(User.t()) :: String.t()
  def call(user) do
    # TODO: move to a command
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end
end
