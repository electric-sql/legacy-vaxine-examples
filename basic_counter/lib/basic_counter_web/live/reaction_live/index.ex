defmodule CountersWeb.ReactionLive.Index do
  use CountersWeb, :live_view

  alias Counters.Reactions
  alias Counters.Reactions.Reaction
  alias CountersWeb.Live.ReactionCounter

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :reactions, [])}
  end
end
