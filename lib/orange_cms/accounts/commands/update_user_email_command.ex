defmodule OrangeCms.Accounts.UpdateUserEmailCommand do
  @moduledoc """
  This module is responsible for updating a user's email.
  """
  use OrangeCms, :command

  alias OrangeCms.Accounts.User
  alias OrangeCms.Accounts.UserToken

  @doc """
  This function is responsible for updating a user's email.
  It verifies the token and the context, and then updates the user's email.
  """
  @spec call(User.t(), String.t()) :: {:ok, User.t()} | {:error, term()}
  def call(user, token) do
    context = "change:#{user.email}"

    with {:ok, query} <- UserToken.verify_change_email_token_query(token, context),
         %UserToken{sent_to: email} <- Repo.one(query),
         {:ok, %{user: user}} <- Repo.transaction(user_email_multi(user, email, context)) do
      {:ok, user}
    else
      _ -> {:error, :invalid_token}
    end
  end

  defp user_email_multi(user, email, context) do
    changeset =
      user
      |> User.email_changeset(%{email: email})
      |> User.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, [context]))
  end
end
