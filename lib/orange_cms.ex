defmodule OrangeCms do
  @moduledoc """
  OrangeCms keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def context do
    quote do
      import Ecto.Query, warn: false

      alias OrangeCms.Repo
    end
  end

  def schema do
    quote do
      use Ecto.Schema

      import Ecto.Changeset
      import Ecto.Query, warn: false

      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
    end
  end

  @doc """
  When used, dispatch to the appropriate context/schema/service/repo/finder
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  def put_actor(actor) do
    Process.put(:actor, actor)
  end

  def get_actor do
    Process.get(:actor)
  end

  def change_actor(changeset, key) do
    case get_actor() do
      %{id: id} -> Ecto.Changeset.put_change(changeset, key, id)
      _ -> changeset
    end
  end
end
