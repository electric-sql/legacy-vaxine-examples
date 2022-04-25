defmodule CountersWeb.ReactionLive.Index do
  use CountersWeb, :live_view

  alias CountersWeb.Live.ReactionCounter
  alias Phoenix.Socket.Broadcast

  @topic "reactions"

  @impl true
  def mount(_params, _session, socket) do
    CountersWeb.Endpoint.subscribe(@topic)
    {:ok, assign(socket, :reactions, [])}
  end

  @impl true
  def handle_info(%Broadcast{event: id, payload: count}, socket) do
    send_update(ReactionCounter, id: id, count: count)
    {:noreply, socket}
  end
end
