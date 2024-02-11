defmodule OrangeCms.Accounts.ResetUserPasswordCommand do
  @moduledoc """
  This module is responsible for resetting a user's password.
  """
  use OrangeCms, :command

  alias OrangeCms.Accounts.User
  alias OrangeCms.Accounts.UserToken

  def call(user, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.password_changeset(user, attrs))
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end
end
