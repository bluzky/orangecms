defmodule OrangeCms.Accounts.CreateUserCommand do
  @moduledoc """
  Create user command
  """
  use OrangeCms, :command

  alias OrangeCms.Accounts.User

  @spec call(map) :: {:ok, User.t()} | {:error, term}
  def call(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
    |> handle_result()
  end

  defp handle_result({:ok, user}) do
    {:ok, user}
  end

  defp handle_result({:error, changeset}) do
    {:error, changeset}
  end
end
