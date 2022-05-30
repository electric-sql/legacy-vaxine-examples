defmodule AdvancedCounterWeb.LatencyMatrixLive.Index do
  use AdvancedCounterWeb, :live_view
  alias AdvancedCounterWeb.RelayIntegration
  import AdvancedCounterWeb.LatencyMatrixLive.Map
  import AdvancedCounterWeb.LatencyMatrixLive.ResultComponents

  @databases ["cloudsql", "antidote", "cockroach"]

  @database_data %{
    "antidote" => %{
      name: "Vaxine DB",
      information: """
      We're running a single node in each region. Conflict-free replicated
      data types guarantee that we can accept writes and still arrive at a consistent state
      without a "main" server.
      """
    },
    "cloudsql" => %{
      name: "Hosted PostgreSQL",
      information: """
      We're using Google Cloud SQL version of hosted PostgreSQL to provide comparison to how a lot
      of companies are usually dealing with their data. Write server is in europe-west2.
      """
    },
    "cockroach" => %{
      name: "Cockroach DB",
      information: """
      We're running a multi-region CockroachDB cluster without regional table localities. There is a node
      set up in each region.
      """
    }
  }

  @animation_steps [:distribution, :preparation, :execution, :collection, :completion]

  @animations %{
    distribution: 2800,
    preparation: 2800,
    execution: 10000,
    collection: 3000
  }

  @latency_ui_modifier 4

  def mount(_params, _session, socket) do
    relays =
      Application.fetch_env!(:advanced_counter_web, :relay_list)
      |> Map.new(fn {region, url} -> {url, region} end)

    latency_map =
      relays
      |> Map.keys()
      |> Map.new(&{&1, Map.new(@databases, fn db -> {db, nil} end)})

    socket =
      socket
      |> assign(:latency_map, latency_map)
      |> assign(:animation_latency_map, latency_map)
      |> assign(:state, :ready)
      |> assign(:ui_state, :ready)
      |> assign(:animations, @animations)
      |> assign(:relays, relays)
      |> assign(:databases, @databases)
      |> assign(:database_data, @database_data)

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
      |> Enum.to_list()
      |> then(&send(parent, {:latency_list, &1}))
    end)

    Process.send_after(self(), {:complete, :distribution}, @animations.distribution)

    timer =
      Process.send_after(
        self(),
        {:complete, :preparation},
        @animations.distribution + @animations.preparation
      )

    socket
    |> assign(:state, :started)
    |> assign(:ui_state, :distribution)
    |> assign(:preparation_timer, timer)
    |> push_event("start-animation-step", %{step: :distribution})
    |> then(&{:noreply, &1})
  end

  def handle_event("animation-ended", _, socket) do
    socket
    |> assign(:state, :complete)
    |> then(&{:noreply, &1})
  end

  def handle_info({:relay, {server, database, response}}, socket) do
    {:noreply, update(socket, :latency_map, &put_in(&1, [server, database], response))}
  end

  def handle_info({:latency_list, latency_list}, socket) do
    latency_map = latency_list_to_map(latency_list)

    animation_latency_list =
      Enum.map(latency_list, fn
        {server, db, {:ok, latency}} -> {server, db, latency * @latency_ui_modifier}
        {server, db, _} -> {server, db, @animations.execution}
      end)

    animation_latency_map = latency_list_to_map(animation_latency_list)

    execution_step_length =
      animation_latency_list
      |> Enum.map(&elem(&1, 2))
      # Find the longest excepted animation
      |> Enum.max()
      |> ceil()
      # Add a second so that UI isn't jumpy
      |> then(&(&1 + 1000))

    time_left = Process.read_timer(socket.assigns.preparation_timer) || 0

    Process.send_after(self(), {:complete, :execution}, time_left + execution_step_length)

    Process.send_after(
      self(),
      {:complete, :collection},
      time_left + execution_step_length + @animations.collection
    )

    socket
    |> assign(:latency_map, latency_map)
    |> assign(:animation_latency_map, animation_latency_map)
    |> update(:animations, &Map.put(&1, :execution, execution_step_length))
    |> assign(:state, :received)
    |> then(&{:noreply, &1})
  end

  def handle_info({:complete, :collection}, socket) do
    next = next_animation_step(:collection)

    socket
    |> assign(:ui_state, next)
    |> assign(:state, :complete)
    |> then(&{:noreply, &1})
  end

  def handle_info({:complete, step}, socket) do
    next = next_animation_step(step)

    socket
    |> assign(:ui_state, next)
    |> push_event("start-animation-step", %{step: next})
    |> then(&{:noreply, &1})
  end

  defp next_animation_step(current) when current in @animation_steps do
    [^current, next | _] = Enum.drop_while(@animation_steps, &(&1 != current))
    next
  end

  def step_complete?(current, target) do
    Enum.find_index(@animation_steps, &(&1 == current)) >=
      Enum.find_index(@animation_steps, &(&1 == target))
  end

  defp latency_list_to_map(latency_list) do
    Enum.reduce(latency_list, %{}, fn
      {server, database, response}, map ->
        map
        |> Map.put_new(server, %{})
        |> Map.update!(server, &Map.put(&1, database, response))
    end)
  end
end
