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

  def increment_reaction_count!(id) do
    reaction = Repo.get(Reaction, id) || %Reaction{id: id, count: 0}

    reaction
    |> Reaction.increment()
    |> Repo.insert_or_update!()
    |> Map.fetch!(:count)
  end
end
