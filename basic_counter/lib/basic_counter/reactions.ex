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
  def get_reaction_count!(id), do: Repo.get!(Reaction, id).count

  def increment_reaction_count!(id) do
    from(r in Reaction, where: r.id == ^id, select: r.count)
    |> Repo.update_all(inc: [count: 1])
    |> then(fn {_, results} -> hd(results) end)
  end
end
