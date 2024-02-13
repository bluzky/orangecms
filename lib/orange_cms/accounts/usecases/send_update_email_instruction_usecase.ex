defmodule OrangeCms.Accounts.SendUpdateEmailInstructionUsecase do
  @moduledoc """
  This module is responsible for sending an email to the user with instructions to update their email.

  1. validate the user's password and email changes
  2. create a new email token and save it to the database
  3. send an email with the new email token
  """

  alias OrangeCms.Accounts.User
  alias OrangeCms.Accounts.UserNotifier
  alias OrangeCms.Accounts.UserToken
  alias OrangeCms.Repo

  def call(original_user, password, attrs, update_email_url_fun) when is_function(update_email_url_fun, 1) do
    with_result =
      with {:ok, user} <- validate_params(original_user, password, attrs),
           encoded_token <- build_token(user, original_user.email) do
        deliver_instructions(user, encoded_token, update_email_url_fun)
      end

    handle_result(with_result)
  end

  defp validate_params(user, password, attrs) do
    user
    |> User.email_changeset(attrs)
    |> User.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  # TODO: move this to a separate command
  defp build_token(user, current_email) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "change:#{current_email}")

    Repo.insert!(user_token)
    encoded_token
  end

  defp deliver_instructions(%User{} = user, encoded_token, update_email_url_fun) do
    UserNotifier.deliver_update_email_instructions(user, update_email_url_fun.(encoded_token))
  end

  defp handle_result({:ok, email}), do: {:ok, email}
  defp handle_result({:error, changeset}), do: {:error, changeset}
end
