defmodule OrangeCms.Accounts.SendConfirmationInstructionCommand do
  @moduledoc """
  Validate user and send email to user
  """
  use OrangeCms, :command

  alias OrangeCms.Accounts.UserNotifier
  alias OrangeCms.Accounts.UserToken

  def call(user, confirmation_url_fun) do
    with :ok <- validate_user_not_confirmed(user),
         encoded_token <- generate_confirmation_token(user) do
      UserNotifier.deliver_confirmation_instructions(user, confirmation_url_fun.(encoded_token))
    end
  end

  defp validate_user_not_confirmed(user) do
    if user.confirmed_at do
      {:error, :already_confirmed}
    else
      :ok
    end
  end

  defp generate_confirmation_token(user) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "confirm")
    Repo.insert!(user_token)
    encoded_token
  end
end
