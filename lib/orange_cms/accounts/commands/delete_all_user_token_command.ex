defmodule OrangeCms.Accounts.DeleteAllUserTokenCommand do
  @moduledoc """
  Build user token query and delete all token for specific contexts

  Context could be `:all` for all token or limit to list of specific contexts
  """

  use OrangeCms, :command

  alias OrangeCms.Accounts.UserToken
  alias OrangeCms.Accounts.User

  @spec call(User.t(), String.t() | atom()) :: :ok
  def call(user, context) do
    query = user_and_contexts_query(user, context)
    Repo.delete_all(query)
  end

    defp user_and_contexts_query(user, :all) do
    from t in UserToken, where: t.user_id == ^user.id
  end

  defp user_and_contexts_query(user, [_ | _] = contexts) do
    from t in UserToken, where: t.user_id == ^user.id and t.context in ^contexts
  end
end
