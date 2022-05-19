defmodule Counters.Reactions do
  @moduledoc """
  The Reactions context.
  """

  import Ecto.Query, warn: false
  alias Counters.Repo

  alias Counters.Reactions.Reaction

  @doc """
  Gets a single reaction.
  """
  def get_reaction_count!(id) do
    case Repo.get(Reaction, id) do
      nil -> 0
      %{count: count} -> count
    end
  end

  def list_reaction_counts(ids) do
    map =
      from(r in Reaction, where: r.id in ^ids)
      |> Repo.all()
      |> Map.new(fn %Reaction{id: id, count: count} -> {id, count} end)

    Enum.reduce(ids, map, &Map.put_new(&2, &1, 0))
  end

  def increment_reaction_count!(id) do
    reaction = Repo.get(Reaction, id) || %Reaction{id: id, count: 0}

    reaction
    |> Reaction.increment()
    |> Repo.insert_or_update!()
    |> Map.fetch!(:count)
  end
end
