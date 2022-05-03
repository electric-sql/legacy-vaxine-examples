defmodule CountersWeb.Live.ReactionCounter do
  use CountersWeb, :live_component
  @topic "reactions"

  def render(assigns) do
    ~H"""
    <div class="my-4 bg-white p-4 rounded shadow dark:bg-blackish">
      <h3 class="text-xl mb-2"><%= render_slot(@inner_block) %></h3>
      <div class="">
        <button
          class="bg-accent hover:bg-accent-light dark:bg-accent-dark dark:hover:bg-accent transition-colors p-2 w-20 text-accent-foreground font-bold rounded"
          phx-click="inc"
          phx-target={@myself}
        >
          🤩 <%= @count %>
        </button>&nbsp;
        <%= if @write_time do %>
          Write took <%= @write_time |> us_to_ms() %> ms,
          avg: <%= @write_time_history |> get_avg_write_time() |> us_to_ms() %> ms
        <% else %>
          Click the reaction to measure write latency!
        <% end %>
      </div>
    </div>
    """
  end

  defp get_avg_write_time([]), do: nil

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
      |> assign(:write_time, nil)
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
