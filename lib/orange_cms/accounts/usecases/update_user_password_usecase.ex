defmodule OrangeCms.Accounts.UpdateUserPasswordUsecase do
  @moduledoc """
  This module is responsible for updating a user's password.
  """

  def call(user, current_password, attrs) do
    user
    |> OrangeCms.Accounts.UpdateUserPasswordCommand.call(current_password, attrs)
    |> handle_result()
  end

  defp handle_result({:ok, user}), do: {:ok, user}
  defp handle_result({:error, changeset}), do: {:error, changeset}
end
