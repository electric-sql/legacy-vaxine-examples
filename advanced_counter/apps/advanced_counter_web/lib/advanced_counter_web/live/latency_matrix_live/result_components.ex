defmodule AdvancedCounterWeb.LatencyMatrixLive.ResultComponents do
  use AdvancedCounterWeb, :component

  def results(assigns) do
    latency_list = valid_latencies(assigns.latency_map)
    mean = mean(latency_list)
    deviation = std_deviation(latency_list)

    assigns =
      assigns
      |> assign(:latency_list, latency_list)
      |> assign(:mean, mean)
      |> assign(:std_deviation, deviation)
      |> assign(:deviation_map, deviation_map(assigns.latency_map, mean, deviation))

    ~H"""
    <div class="overflow-x-auto">
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
          <tr class={if db == "antidote", do: "bg-slate-100 dark:bg-whiteish-invert"}>
            <th class="font-normal p-2 pr-4"><%= @database_data[db].name %></th>
            <%= for {server, name} <- @relays do %>
              <td class="p-3 border-l-[1px] border-slate-200 text-center">
                <%= case @latency_map[server][db] do %>
                  <% {:ok, value} -> %>
                    <.latency value={value} deviations={@deviation_map[server][db]} />
                  <% {:error, reason} -> %>
                    <.latency_error id={"error-#{name}-#{db}"} reason={reason} />
                <% end %>
              </td>
            <% end %>
          </tr>
        <% end %>
      </table>
    </div>

    <div class="mt-10 vaxine-prose max-w-full dark:prose-invert prose-headings:mt-4 prose-headings:mb-2">
      <h2>What exactly are we comparing</h2>
      <p>
        This example application sends write operations (counter increments) from
        <%= map_size(@relays) %>
        geo-distributed
        regions to <%= length(@databases) %>
        different databases. Below we explain how these databases are set up
        and what the experiments are demonstrating.
      </p>
      <%= for db <- @databases, %{name: name, information: info} = @database_data[db] do %>
        <section>
          <h3><%= name %>:</h3>
          <%= for info_p <- List.wrap(info) do %>
            <p><%= raw(info_p) %></p>
          <% end %>
        </section>
      <% end %>
    </div>
    """
  end

  defp latency(assigns) do
    ~H"""
    <span
      class="inline-block rounded-xl p-1 px-4 bg-[hsl(var(--heatmap-hue),90%,80%)] dark:bg-[hsl(var(--heatmap-hue),50%,60%)] dark:text-blackish"
      style={"--heatmap-hue: #{hue(@deviations)}"}
    >
      <%= Float.round(@value, 1) %>ms
    </span>
    """
  end

  defp latency_error(assigns) do
    ~H"""
    <div
      class="relative inline-block cursor-pointer"
      aria-describedby={@id <> "-tooltip"}
      id={@id}
      phx-hook="WithTooltip"
      tabindex="1"
    >
      <svg
        xmlns="http://www.w3.org/2000/svg"
        viewBox="0 0 512 512"
        class="w-6 mt-2 fill-red-500 mx-auto"
      >
        <!--! Font Awesome Pro 6.1.1 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license (Commercial License) Copyright 2022 Fonticons, Inc. -->
        <path d="M256 0C114.6 0 0 114.6 0 256s114.6 256 256 256s256-114.6 256-256S397.4 0 256 0zM232 152C232 138.8 242.8 128 256 128s24 10.75 24 24v128c0 13.25-10.75 24-24 24S232 293.3 232 280V152zM256 400c-17.36 0-31.44-14.08-31.44-31.44c0-17.36 14.07-31.44 31.44-31.44s31.44 14.08 31.44 31.44C287.4 385.9 273.4 400 256 400z" />
      </svg>
      <div
        id={"#{@id}-tooltip"}
        class="bg-white p-2 shadow-lg rounded absolute whitespace-nowrap top-0 left-1/2 -translate-y-full ring-2 ring-red-200 -translate-x-1/2 hidden"
        role="tooltip"
      >
        <%= @reason %>
      </div>
    </div>
    """
  end

  defp valid_latencies(latency_map) do
    latency_map
    |> Map.values()
    |> Enum.flat_map(&Map.values/1)
    |> Enum.filter(&match?({:ok, _}, &1))
    |> Enum.map(&elem(&1, 1))
  end

  defp mean(values) when is_list(values), do: Enum.sum(values) / length(values)

  defp variance(values) when is_list(values) do
    m = mean(values)

    values
    |> Enum.map(&:math.pow(&1 - m, 2))
    |> mean()
  end

  defp std_deviation(values) when is_list(values) do
    values
    |> variance()
    |> :math.sqrt()
  end

  defp deviation_map(latency_map, mean, deviation) do
    Map.new(latency_map, fn {server, db_map} ->
      db_map
      |> Enum.filter(&match?({_, {:ok, _}}, &1))
      |> Map.new(fn {db, {:ok, value}} ->
        {db, (value - mean) / deviation}
      end)
      |> then(&{server, &1})
    end)
  end

  defp hue(value, from..to \\ -2..2) do
    percentage = (value - from) / (to - from)
    (1 - percentage) * 120
  end
end
