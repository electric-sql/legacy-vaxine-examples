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

  def connection_warmup("cloudsql"), do: Ecto.Adapters.SQL.query(CloudSql, "SELECT 1")
  def connection_warmup("cockroach"), do: Ecto.Adapters.SQL.query(Cockroach, "SELECT 1")
  def connection_warmup("antidote"), do: {:ok, nil}

  def increment(db, counter_id, retries \\ 3)

  def increment("cloudsql", counter_id, _),
    do: CloudSql.transaction(postgres_increment_multi(counter_id))

  def increment("cockroach", counter_id, retries) do
    Cockroach.transaction(postgres_increment_multi(counter_id))
  rescue
    e in Postgrex.Error ->
      case {e.postgres, retries} do
        {%{code: :serialization_failure}, x} when x > 0 ->
          # Retry the operation per the Cockroach docs
          # https://www.cockroachlabs.com/docs/v22.1/transactions#client-side-intervention
          increment("cockroach", counter_id, retries - 1)
        _ ->
          # Unknown error, we should reraise that
          reraise e, __STACKTRACE__
      end
  end

  def increment("antidote", counter_id, _),
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
