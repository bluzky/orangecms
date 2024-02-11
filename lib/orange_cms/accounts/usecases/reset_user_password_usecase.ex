defmodule OrangeCms.Accounts.ResetUserPasswordUsecase do
  @moduledoc """
  This module is responsible for resetting a user's password.
  """

  def call(user, attrs) do
    user
    |> OrangeCms.Accounts.ResetUserPasswordCommand.call(attrs)
    |> handle_result()
  end

  defp handle_result({:ok, user}), do: {:ok, user}
  defp handle_result({:error, changeset}), do: {:error, changeset}
end
