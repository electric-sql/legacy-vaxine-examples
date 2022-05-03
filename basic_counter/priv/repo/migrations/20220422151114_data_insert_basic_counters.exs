defmodule Counters.Repo.Migrations.DataInsertBasicCounters do
  use Ecto.Migration
  alias Counters.Reactions.Reaction

  def up do
    repo().insert(%Reaction{id: "multi-user", count: 0}, on_conflict: :nothing)
    repo().insert(%Reaction{id: "multiplayer", count: 0}, on_conflict: :nothing)
    repo().insert(%Reaction{id: "geo-distributed", count: 0}, on_conflict: :nothing)
    repo().insert(%Reaction{id: "other", count: 0}, on_conflict: :nothing)
  end
end
