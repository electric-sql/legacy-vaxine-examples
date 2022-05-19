defmodule Counters.Reactions.Checker do
  use GenServer

  @check_time_ms 500
  @topic "reactions"

  def start_link(initial_ids) do
    GenServer.start_link(__MODULE__, initial_ids, name: __MODULE__)
  end

  def add_ids(server \\ __MODULE__, ids) do
    GenServer.cast(server, {:add, ids})
  end

  @impl true
  def init(ids) do
    {:ok, ids, {:continue, :init_timer}}
  end

  @impl true
  def handle_continue(:init_timer, state) do
    :timer.send_interval(@check_time_ms, :check_and_broadcast)

    {:noreply, state}
  end

  @impl true
  def handle_info(:check_and_broadcast, ids) do
    Counters.Reactions.list_reaction_counts(ids)
    |> Enum.each(fn {id, count} -> CountersWeb.Endpoint.broadcast!(@topic, id, count) end)

    {:noreply, ids}
  end

  @impl true
  def handle_cast({:add, ids}, state) do
    state = Enum.uniq(state ++ ids)

    {:noreply, state}
  end
end
