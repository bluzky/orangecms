defmodule OrangeCms.Accounts.DeleteUserTokenCommand do
  @moduledoc false

  use OrangeCms, :command

  alias OrangeCms.Accounts.UserToken

  @spec call(String.t(), String.t()) :: :ok
  def call(token, context) do
    query = from(t in UserToken, where: [token: ^token, context: ^context])
    Repo.delete_all(query)
  end
end
