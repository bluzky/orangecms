defmodule OrangeCms.Accounts.UpdateUserPasswordCommand do
  @moduledoc """
  This module is responsible for updating a user's password.
  """
  use OrangeCms, :command

  alias OrangeCms.Accounts.User
  alias OrangeCms.Accounts.UserToken

  def call(user, password, attrs) do
    changeset =
      user
      |> User.password_changeset(attrs)
      |> User.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end
end
