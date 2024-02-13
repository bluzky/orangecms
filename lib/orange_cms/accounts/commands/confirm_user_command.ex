defmodule OrangeCms.Accounts.ConfirmUserCommand do
  @moduledoc """
  This module is responsible for confirming a user by setting confirmed_at and deleting the confirmation token.
  """

  use OrangeCms, :command

  alias OrangeCms.Accounts.User
  alias OrangeCms.Accounts.UserToken

  @spec call(User.t()) :: {:ok, User.t()} | {:error, term()}
  def call(user) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.confirm_changeset(user))
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, ["confirm"]))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, _, error, _} -> {:error, error}
    end
  end
end
