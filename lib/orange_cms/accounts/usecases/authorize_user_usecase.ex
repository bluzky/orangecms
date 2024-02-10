defmodule OrangeCms.Accounts.AuthorizeUserUsecase do
  @moduledoc """
  Authorize user usecase
  """
  alias OrangeCms.Accounts.FindUserQuery
  alias OrangeCms.Accounts.User

  @spec call(String.t(), String.t()) :: {:ok, User.t()} | {:error, :unauthorized} | {:error, :not_found}
  def call(email, password) do
    %{email: email, is_blocked: false}
    |> FindUserQuery.run()
    |> validate_password(password)
  end

  defp validate_password(nil, _) do
    {:error, :not_found}
  end

  defp validate_password(user, password) do
    if User.valid_password?(user, password) do
      {:ok, user}
    else
      {:error, :unauthorized}
    end
  end
end
