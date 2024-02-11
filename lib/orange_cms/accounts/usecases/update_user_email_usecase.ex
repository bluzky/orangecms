defmodule OrangeCms.Accounts.UpdateUserEmailUsecase do
  @moduledoc """
  This module is responsible for updating a user's email.
  """

  def call(user, token) do
    user
    |> OrangeCms.Accounts.UpdateUserEmailCommand.call(token)
    |> handle_result()
  end

  defp handle_result({:ok, user}), do: {:ok, user}
  defp handle_result({:error, :invalid_token}), do: {:error, :invalid_token}
end
