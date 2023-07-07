defmodule OrangeCms.Shared.Github.Client do
  @moduledoc false
  require Logger

  @endpoint "https://api.github.com/"

  defp new_client(token) do
    Tentacat.Client.new(%{access_token: token}, @endpoint)
  end

  def api(token, func) do
    token
    |> new_client()
    |> func.()
    |> handle_api_response()
  end

  def list_repository(token) do
    api(
      token,
      &Tentacat.Repositories.list_mine(&1, type: "owner")
    )
  end

  def get_content(config, path) do
    api(config.access_token, &Tentacat.Contents.find(&1, config.repo_owner, config.repo_name, path))
  end

  # convert Tentacat API response into new tuple of `{:ok, data}` and `{:error, error}`
  defp handle_api_response(response) do
    case response do
      {status, data, _request} when status >= 200 and status < 300 ->
        {:ok, data}

      {422, _error, _request} ->
        {:error, :validation_failed}

      {404, _error, _request} ->
        {:error, :not_found}

      {401, _error, _request} ->
        {:error, :unauthorized}

      {403, _error, _request} ->
        {:error, :forbidden}

      {_status, error, _request} ->
        {:error, error}
    end
  end
end
