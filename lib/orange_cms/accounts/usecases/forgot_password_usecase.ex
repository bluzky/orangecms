defmodule OrangeCms.Accounts.ForgotPasswordUsecase do
  @moduledoc """
  This module is responsible for sending a password reset email.

  1. find user by email
  2. create a reset token and save it to the database
  3. send an email with the reset token
  """

  alias OrangeCms.Accounts.FindUserUsecase
  alias OrangeCms.Accounts.UserNotifier
  alias OrangeCms.Accounts.UserToken
  alias OrangeCms.Repo

  # TODO: define clear return structure
  def call(current_email, update_email_url_fun) when is_function(update_email_url_fun, 1) do
    with {:ok, user} <- FindUserUsecase.call(email: current_email) do
      encoded_token = init_reset_token(user)
      deliver_reset_email(user, encoded_token, update_email_url_fun)
    end
  end

  defp init_reset_token(user) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "reset_password")

    Repo.insert!(user_token)
    encoded_token
  end

  defp deliver_reset_email(user, encoded_token, update_email_url_fun) do
    UserNotifier.deliver_reset_password_instructions(user, update_email_url_fun.(encoded_token))
  end
end
