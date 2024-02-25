defmodule OrangeCms.Context do
  @moduledoc """
  This module is the context for the OrangeCms application

  A context is a struct which hold commonly data that business logic needs and should aware of.

  Details of the context:
  - actor: The user who is performing the action
  - project: The project that the action is performed on
  - resource: The resource that the action is performed on
  - extra: Extra data that the action needs
  """
  defstruct [:actor, :project, :resource, extra: %{}]

  @doc """
  Create a new empty context
  """
  @spec new() :: %__MODULE__{}
  def new do
    %__MODULE__{}
  end

  @doc """
  Create a new context with given actor, project, resource and extra data
  """
  @spec new(actor :: any, project :: any, resource :: any, extra :: map) :: %__MODULE__{}
  def new(actor, project, resource, extra \\ %{}) do
    %__MODULE__{actor: actor, project: project, resource: resource, extra: extra}
  end

  @doc """
  Create new context with data provided in a map or keyword list
  """
  @spec new(attrs :: map) :: %__MODULE__{}
  def new(attrs) when is_map(attrs) or is_list(attrs) do
    struct(__MODULE__, attrs)
  end

  @doc """
  Get the value of a key from the context. Only accepts atoms as keys

  ## Examples

      iex> context = OrangeCms.Context.new(actor: use, project: project)
      iex> OrangeCms.Context.put(context, :resource, post)
  """
  @spec put(context :: %__MODULE__{}, key :: atom, value :: any) :: %__MODULE__{}
  def put(context, key, value) do
    struct(context, [{key, value}])
  end
end
