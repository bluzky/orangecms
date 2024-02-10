defmodule OrangeCms.Shared.Filter do
  @moduledoc false
  import Ecto.Query

  @doc """
  Filter by map or list of column condition

  Example:

    User
    |> with_filters([name: "John", age: 18])
    |> Repo.all
  """

  def with_filters(query, filters) when is_map(filters) or is_list(filters) do
    Enum.reduce(filters, query, fn {field, value}, query ->
      filter_by(query, field, value)
    end)
  end

  @doc """
  Add negative filter for a map or list of column condition
  """
  def except(query, filters) when is_map(filters) or is_list(filters) do
    Enum.reduce(filters, query, fn {field, value}, query ->
      filter_by(query, field, {:not, value})
    end)
  end

  @doc """
  Add negative filter for a field
  """
  def except(query, field, value) do
    filter_by(query, field, {:not, value})
  end

  @doc """
  New simpler and clear api interface that should be used instead of `apply` and `filter_and`
  """

  def filter_by(query, _column, nil) do
    query
  end

  def filter_by(query, column, {:in, value}) when is_list(value) do
    where(query, [q], field(q, ^column) in ^value)
  end

  def filter_by(query, column, {:not_in, value}) when is_list(value) do
    where(query, [q], field(q, ^column) not in ^value)
  end

  def filter_by(query, column, {:gt, value}) do
    where(query, [q], field(q, ^column) > ^value)
  end

  def filter_by(query, column, {:gte, value}) do
    where(query, [q], field(q, ^column) >= ^value)
  end

  def filter_by(query, column, {:lt, value}) do
    where(query, [q], field(q, ^column) < ^value)
  end

  def filter_by(query, column, {:lte, value}) do
    where(query, [q], field(q, ^column) <= ^value)
  end

  def filter_by(query, column, {:like, value}) do
    where(query, [q], like(field(q, ^column), ^"%#{value}%"))
  end

  def filter_by(query, column, {:ilike, value}) do
    where(query, [q], ilike(field(q, ^column), ^"%#{value}%"))
  end

  def filter_by(query, column, {:starts_with, value}) do
    where(query, [q], like(field(q, ^column), ^"#{value}%"))
  end

  def filter_by(query, column, {:ends_with, value}) do
    where(query, [q], like(field(q, ^column), ^"%#{value}"))
  end

  def filter_by(query, _column, {:between, {nil, nil}}), do: query

  def filter_by(query, column, {:between, {from, nil}}) do
    filter_by(query, column, {:gte, from})
  end

  def filter_by(query, column, {:between, {nil, to}}) do
    filter_by(query, column, {:lte, to})
  end

  def filter_by(query, column, {:between, {from, to}}) do
    where(query, [q], field(q, ^column) >= ^from and field(q, ^column) <= ^to)
  end

  def filter_by(query, column, {:eq, value}) do
    where(query, [q], field(q, ^column) == ^value)
  end

  def filter_by(query, column, {:ne, value}) do
    where(query, [q], field(q, ^column) != ^value)
  end

  def filter_by(query, column, {:not, value}) do
    filter_by(query, column, {:ne, value})
  end

  # default use `in` operator for list
  def filter_by(query, column, value) when is_list(value) do
    filter_by(query, column, {:in, value})
  end

  # default using `eq` operator
  def filter_by(query, column, value) do
    filter_by(query, column, {:eq, value})
  end
end
