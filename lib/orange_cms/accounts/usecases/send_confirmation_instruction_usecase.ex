defmodule OrangeCms.Accounts.SendConfirmationInstructionUsecase do
  @moduledoc """
  Send confirmation instruction to the user
  1. find user with given email
  2. Deliver instruction email if user exist
  """
  use OrangeCms, :usecase

  alias OrangeCms.Accounts.FindUserUsecase
  alias OrangeCms.Accounts.SendConfirmationInstructionCommand

  def call(email, confirmation_url_fun) when is_function(confirmation_url_fun, 1) do
    with {:ok, user} <- FindUserUsecase.call(email: email) do
      user
      |> SendConfirmationInstructionCommand.call(confirmation_url_fun)
      |> handle_result()
    end
  end

  defp handle_result({:ok, email}), do: {:ok, email}
  defp handle_result(error), do: error
end
