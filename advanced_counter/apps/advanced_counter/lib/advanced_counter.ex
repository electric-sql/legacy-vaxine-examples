defmodule AdvancedCounter do
  @moduledoc """
  AdvancedCounter keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias AdvancedCounter.Repos.CloudSql, as: Repo
  alias AdvancedCounter.Counter

  import Ecto.Query

  def get(db, counter_id)
  def get("cloudsql", counter_id), do: Repo.one(Counter, counter_id)

  def increment(db, counter_id)
  def increment("cloudsql", counter_id) do
    postgres_increment_multi(counter_id)
    |> Repo.transaction()
  end

  defp postgres_increment_multi(counter_id) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:insert_counter, fn repo, _ ->
      case repo.get(Counter, counter_id) do
        nil -> repo.insert(%Counter{id: counter_id, value: 0})
        value -> {:ok, value}
      end
    end)
    |> Ecto.Multi.update_all(:increment, where(Counter, [c], c.id == ^counter_id), inc: [value: 1])
  end
end
