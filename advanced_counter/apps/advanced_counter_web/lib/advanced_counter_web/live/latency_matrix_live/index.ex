defmodule AdvancedCounterWeb.LatencyMatrixLive.Index do
  use AdvancedCounterWeb, :live_view
  alias AdvancedCounterWeb.RelayIntegration

  @databases ["cloudsql", "cockroach"]
  @servers ["http://localhost:4001", "http://localhost:4002"]

  def mount(_params, _session, socket) do
    latency_map = Map.new(@servers, &{&1, Map.new(@databases, fn db -> {db, nil} end)})

    socket =
      socket
      |> assign(:latency_map, latency_map)
      |> assign(:servers, @servers)
      |> assign(:databases, @databases)

    {:ok, socket}
  end

  def handle_event("test-latency", _, socket) do
    RelayIntegration.stream_counter_increment(@servers, @databases, "global-latency-test")
    |> Stream.each(&send(self(), {:relay, &1}))
    |> Stream.run()

    {:noreply, update(socket, :latency_map, &reset_latency_map(&1, :loading))}
  end

  def handle_info({:relay, {server, database, response}}, socket) do
    {:noreply, update(socket, :latency_map, &put_in(&1, [server, database], response))}
  end

  defp reset_latency_map(map, value) do
    Map.new(map, fn {srv, v} -> {srv, Map.new(v, fn {db, _} -> {db, value} end)} end)
  end
end
