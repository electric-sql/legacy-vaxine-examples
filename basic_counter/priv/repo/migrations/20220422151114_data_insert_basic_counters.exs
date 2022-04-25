defmodule Counters.Repo.Migrations.DataInsertBasicCounters do
  use Ecto.Migration
  alias Counters.Reactions.Reaction

  def up do
    repo().insert(%Reaction{id: "multiplayer-gaming", count: 0})
    repo().insert(%Reaction{id: "multiuser-apps", count: 0})
    repo().insert(%Reaction{id: "geodistributed-apps", count: 0})
  end
end
