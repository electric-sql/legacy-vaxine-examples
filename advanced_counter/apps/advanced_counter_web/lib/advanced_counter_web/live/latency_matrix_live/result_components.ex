defmodule AdvancedCounterWeb.LatencyMatrixLive.ResultComponents do
  use AdvancedCounterWeb, :component

  def results(assigns) do
    ~H"""
    <table>
      <tr>
        <th class="font-normal"></th>
        <%= for {_, name} <- @relays do %>
          <th class="font-normal p-2 px-4">
            <%= name %>
          </th>
        <% end %>
      </tr>
      <%= for db <- @databases do %>
        <tr>
          <th class="font-normal p-2 pl-0 pr-4"><%= db %></th>
          <%= for {server, _} <- @relays do %>
            <td class="p-3 border-l-[1px] border-slate-200">
              <%= case @latency_map[server][db] do %>
                <% nil -> %>
                  &nbsp;
                <% :loading -> %>
                  Loading...
                <% {:ok, value} -> %>
                  <%= value %>ms
                <% {:error, reason} -> %>
                  <%= reason %>
              <% end %>
            </td>
          <% end %>
        </tr>
      <% end %>
    </table>
    """
  end
end
