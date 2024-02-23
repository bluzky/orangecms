defmodule OrangeCms.Value do
  @moduledoc """
  Module to allow better Value composition. With this module we're able to
  compose complex structures faster and simpler.

  A Value's base format can only be a List or a Map.
  """

  @doc """
  Initiate a Value base format as a List

  ## Examples
      iex> init_with_list()
      []
  """
  def init_with_list, do: []

  @doc """
  Initiate a Value base format as a Map

  ## Examples
      iex> init_with_map()
      %{}
  """
  def init_with_map, do: %{}

  @doc """
  Initiate a Value based on a pre-existing Struct.

  ## Examples
      iex> country = %Country{name: "Portugal", region: "Europe", slug: "slug", code: "code"}
      %Country{name: "Portugal", region: "Europe", slug: "slug", code: "code"}
      iex> init(country)
      %{name: "Portugal", region: "Europe", slug: "slug", code: "code"}

      iex> init(%{a: 1})
      %{a: 1}
      iex> init([1, 2, 3])
      [1, 2, 3]
  """
  def init(%{__struct__: _} = value) do
    value
    |> Map.from_struct()
    |> Map.drop([:__meta__, :__struct__])
  end

  # Initiate a Value based on a pre-existing Map or List.
  def init(value) do
    value
  end

  @doc """
  Remove specified keys from a Value.

  ## Examples
      iex> response = init(%{a: 1, b: 2})
      %{a: 1, b: 2}
      iex> except(response, [:a])
      %{b: 2}
  """
  def except(value, keys) when is_map(value), do: Map.drop(value, keys)

  @doc """
  Return only specified keys from a Value.

  ## Examples
      iex> response = init(%{a: 1, b: 2})
      %{a: 1, b: 2}
      iex> only(response, [:a])
      %{a: 1}
  """
  def only(value, keys) when is_map(value), do: Map.take(value, keys)

  @doc """
  Add an item to a Value list.

  ## Examples
      iex> response = init([1, 2, 3])
      [1, 2, 3]
      iex> add(response, 4)
      [4, 1, 2, 3]

      iex> response = init(%{a: 1, b: 2})
      %{a: 1, b: 2}
      iex> add(response, %{c: 3})
      %{a: 1, b: 2, c: 3}
      iex> add(response, c: 3)
      %{a: 1, b: 2, c: 3}
  """
  def add(value, entry) when is_list(value), do: [entry | value]

  # Add an item to a value map. Accepts a Map or a simple keyword list.
  def add(value, entry) when is_map(value) do
    Enum.reduce(entry, value, fn {key, key_value}, acc ->
      Map.put(acc, key, key_value)
    end)
  end

  @doc """
  Removes keys with `nil` values from the map
  """
  def compact(map) do
    map
    |> Enum.reject(fn {_, value} -> is_nil(value) end)
    |> Map.new()
  end

  @doc """
  Modifies provided key by applying provided function.
  If key is not present it won't be updated, no exception be raised.

  ## Examples
      iex> response = init(%{a: 1, b: 2})
      %{a: 1, b: 2}
      iex> modify(response, :b, fn val -> val * 2 end)
      %{a: 1, b: 4}
      iex> modify(response, :c, fn val -> val * 2 end)
      %{a: 1, b: 2}
  """
  def modify(data, key, fun) when is_map(data) and is_function(fun) do
    data
    |> Map.update(key, nil, fun)
    |> compact()
  end

  # @doc """
  # build associations with their own 'Value' modules when their are present,
  # avoiding `nil` or unloaded structs
  # """
  # #   def build_assoc(value_module, assoc, fields \\ nil)
  #   def build_assoc(_value_module, nil, _), do: nil
  #   def build_assoc(_value_module, %Ecto.Association.NotLoaded{}, _), do: nil
  #   def build_assoc(value_module, assoc, nil), do: value_module.build(assoc)
  #   def build_assoc(value_module, assoc, fields), do: value_module.build(assoc, fields)
end
