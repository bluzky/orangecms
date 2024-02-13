defmodule OrangeCms.Accounts.GetUserBySessionTokenUsecase do
  @moduledoc false

  @spec call(String.t()) :: User.t() | nil
  def call(session_token) do
    OrangeCms.Accounts.FindUserByTokenQuery.run(session_token, "session")
  end
end
