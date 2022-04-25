defmodule CountersWeb.Live.ReactionCounter do
  use CountersWeb, :live_component
  @topic "reactions"

  def render(assigns) do
    ~H"""
    <div class="my-4">
      <h3 class="text-lg">
        <span class="text-2xl"><%= @emoji %></span><%= render_slot(@inner_block) %>
      </h3>
      <div>
        <button
          class="bg-accent p-2 w-20 text-accent-foreground font-bold rounded-lg"
          phx-click="inc"
          phx-target={@myself}
        >
          🤩 <%= @count %>
        </button>
        Write took <%= @write_time |> us_to_ms %> ms, avg:
        <%= @write_time_history |> get_avg_write_time |> us_to_ms %> ms
      </div>
    </div>
    """
  end

  defp get_avg_write_time([]), do: 0

  defp get_avg_write_time(write_time_history) do
    round(Enum.sum(write_time_history) / length(write_time_history))
  end

  defp us_to_ms(number) when is_number(number) do
    Float.round(number / 1000, 2)
  end

  def preload(assigns) do
    assigns =
      Enum.map(assigns, &Map.put(&1, :count, Counters.Reactions.get_reaction_count!(&1.id)))

    Counters.Reactions.Checker.add_ids(Enum.map(assigns, & &1.id))

    assigns
  end

  def mount(socket) do
    socket =
      socket
      |> assign(:count, 0)
      |> assign(:write_time, 0)
      |> assign(:write_time_history, [])

    {:ok, socket}
  end

  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  def handle_event("inc", _, socket) do
    {time, count} =
      :timer.tc(&Counters.Reactions.increment_reaction_count!/1, [socket.assigns.id])

    CountersWeb.Endpoint.broadcast_from!(self(), @topic, socket.assigns.id, count)

    socket =
      socket
      |> assign(:count, count)
      |> assign(:write_time, time)
      |> update(:write_time_history, &[time | &1])

    {:noreply, socket}
  end
end
