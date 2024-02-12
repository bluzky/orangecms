defmodule OrangeCms.Accounts.FindUserByTokenQuery do
  @moduledoc false

  use OrangeCms, :query

  alias OrangeCms.Accounts.UserToken

  @session_validity_in_days 60

  @doc """
  Checks if the token is valid and returns its underlying lookup query.
  The query returns the user found by the token, if any.
  The token is valid if it matches the value in the database and it has
  not expired

  1. get the validity in days for the context
     avalaible contexts:
      - "session"
  2. build the query
  3. execute the query and get one user
  """

  @spec run(String.t(), String.t()) :: User.t() | nil
  def run(token, context) do
    validity_in_days = days_for_context(context)
    query = build_query(token, context, validity_in_days)
    Repo.one(query)
  end

  defp days_for_context("session"), do: @session_validity_in_days

  defp build_query(token_string, context, validity_in_days) when validity_in_days > 0 do
    from(token in UserToken,
      join: user in assoc(token, :user),
      where:
        token.token == ^token_string and
          token.context == ^context and
          token.inserted_at > ago(^validity_in_days, "day"),
      select: user
    )
  end
end
