defmodule OrangeCms.Accounts.RegisterUserCommand do
  @moduledoc """
  Register user command
  """
  use OrangeCms, :command

  alias OrangeCms.Accounts.User

  @spec call(map) :: {:ok, User.t()} | {:error, term}
  def call(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
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
