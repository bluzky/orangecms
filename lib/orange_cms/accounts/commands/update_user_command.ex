defmodule OrangeCms.Accounts.UpdateUserCommand do
  @moduledoc """
  Update user command
  """
  use OrangeCms, :command

  alias OrangeCms.Accounts.User

  @spec call(User.t(), map) :: {:ok, User.t()} | {:error, term}
  def call(user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
    |> handle_result()
  end

  defp handle_result({:ok, user}) do
    {:ok, user}
  end

  defp handle_result({:error, changeset}) do
    {:error, changeset}
  end
end
