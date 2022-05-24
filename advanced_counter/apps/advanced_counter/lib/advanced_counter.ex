defmodule AdvancedCounter do
  @moduledoc """
  AdvancedCounter keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias AdvancedCounter.Repos.CloudSql
  alias AdvancedCounter.Repos.Cockroach
  alias AdvancedCounter.Repos.Antidote
  alias AdvancedCounter.Counter
  alias AdvancedCounter.VaxCounter

  import Ecto.Query

  def get(db, counter_id)
  def get("cloudsql", counter_id), do: CloudSql.one(Counter, counter_id)
  def get("cockroach", counter_id), do: Cockroach.one(Counter, counter_id)
  def get("antidote", counter_id), do: Antidote.one(Counter, counter_id)

  def increment(db, counter_id)

  def increment("cloudsql", counter_id),
    do: CloudSql.transaction(postgres_increment_multi(counter_id))

  def increment("cockroach", counter_id),
    do: Cockroach.transaction(postgres_increment_multi(counter_id))

  def increment("antidote", counter_id),
    do: %VaxCounter{id: counter_id, value: 0} |> VaxCounter.increment() |> Antidote.update()

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
