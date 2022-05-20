defmodule AdvancedCounterWeb.LatencyMatrixLive.Index do
  use AdvancedCounterWeb, :live_view
  alias AdvancedCounterWeb.RelayIntegration

  @databases ["cloudsql", "cockroach"]

  def mount(_params, _session, socket) do
    relays =
      Application.fetch_env!(:advanced_counter_web, :relay_list)
      |> IO.inspect()
      |> Map.new(fn {region, url} -> {url, region} end)

    latency_map =
      relays
      |> Map.keys()
      |> Map.new(&{&1, Map.new(@databases, fn db -> {db, nil} end)})

    socket =
      socket
      |> assign(:latency_map, latency_map)
      |> assign(:relays, relays)
      |> assign(:databases, @databases)

    {:ok, socket}
  end

  def handle_event("test-latency", _, socket) do
    parent = self()

    Task.start(fn ->
      socket.assigns.relays
      |> Map.keys()
      |> RelayIntegration.stream_counter_increment(
        socket.assigns.databases,
        "global-latency-test"
      )
      |> Stream.each(&send(parent, {:relay, &1}))
      |> Stream.run()
    end)

    {:noreply, update(socket, :latency_map, &reset_latency_map(&1, :loading))}
  end

  def handle_info({:relay, {server, database, response}}, socket) do
    {:noreply, update(socket, :latency_map, &put_in(&1, [server, database], response))}
  end

  defp reset_latency_map(map, value) do
    Map.new(map, fn {srv, v} -> {srv, Map.new(v, fn {db, _} -> {db, value} end)} end)
  end
end
