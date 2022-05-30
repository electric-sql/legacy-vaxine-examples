defmodule AdvancedCounterWeb.LatencyMatrixLive.Map do
  use AdvancedCounterWeb, :component
  import :math
  alias AdvancedCounterWeb.LatencyMatrixLive.Index, as: View

  @external_resource Path.expand(
                       "static/images/world_map_outline_natural_projection.svg",
                       :code.priv_dir(:advanced_counter_web)
                     )
  @map_svg File.read!(@external_resource)

  # Server locations of GCP regions to draw when we make a request
  @locations %{
    "asia-east1" => {24.0808, 120.5423},
    "asia-east2" => {22.2793, 114.1628},
    "asia-northeast1" => {35.6828, 139.7595},
    "asia-northeast2" => {34.6938, 135.5015},
    "asia-northeast3" => {37.5667, 126.9783},
    "asia-south1" => {19.076, 72.8774},
    "asia-south2" => {28.6517, 77.2219},
    "asia-southeast1" => {1.3396, 103.7073},
    "asia-southeast2" => {-6.1754, 106.8272},
    "australia-southeast1" => {-33.7685, 150.9569},
    "australia-southeast2" => {-37.8142, 144.9632},
    "europe-central2" => {52.232, 21.0067},
    "europe-north1" => {60.5689, 27.1882},
    "europe-southwest1" => {40.4167, -3.7036},
    "europe-west1" => {50.4477, 3.8195},
    "europe-west2" => {51.5073, -0.1276},
    "europe-west3" => {50.1106, 8.6821},
    "europe-west4" => {53.4484, 6.8465},
    "europe-west6" => {47.3744, 8.541},
    "europe-west8" => {45.4642, 9.1898},
    "europe-west9" => {48.8589, 2.32},
    "northamerica-northeast1" => {45.5032, -73.5698},
    "northamerica-northeast2" => {43.6535, -79.3839},
    "southamerica-east1" => {-23.5507, -46.6334},
    "southamerica-west1" => {9.8695, -83.7981},
    "us-central1" => {41.2588, -95.8519},
    "us-east1" => {33.196, -80.0131},
    "us-east4" => {39.0437, -77.4875},
    "us-east5" => {39.9623, -83.0007},
    "us-west1" => {45.6015, -121.1842},
    "us-west2" => {34.0537, -118.2428},
    "us-west3" => {40.7596, -111.8868},
    "us-west4" => {36.1673, -115.1485}
  }

  def progress_steps(assigns) do
    lines = [
      distribution: "Sending out execution instructions to relays...",
      preparation: "Warming up database connections on the relays... ",
      execution: "Measuring write latency from relay to a database node in the same region...",
      collection: "Collecting results... "
    ]

    assigns = assign(assigns, :lines, lines)

    ~H"""
    <div class="bg-blackish text-whiteish p-4 rounded">
      <%= for {show_on, text} <- @lines, View.step_complete?(@current_step, show_on) do %>
        <.progress_line loading={show_on == @current_step} text={text} />
      <% end %>
    </div>
    """
  end

  defp hash(string, length \\ 7) do
    :crypto.hash(:md5, string) |> Base.encode16(case: :lower) |> String.slice(0, length)
  end

  defp progress_line(assigns) do
    ~H"""
    <p class="font-iosevka">
      &gt; <%= @text %>
      <%= if @loading do %>
        <span id={"loading-#{hash(@text)}"} class="text-yellow-300" phx-hook="LoadingIndicator" />
      <% else %>
        <span class="text-green-600">Done</span>
      <% end %>
    </p>
    """
  end

  defp world_map(assigns) do
    assigns = assign_new(assigns, :class, fn -> "fill-slate-300 dark:fill-slate-600" end)
    svg = assign_map_classes(@map_svg, assigns.class)

    ~H"""
    <%= raw(svg) %>
    """
  end

  defp svg_server_node(assigns) do
    ~H"""
    <circle cx={@x} cy={@y} r="60" class="fill-accent origin-center" />
    <circle cx={@x} cy={@y} r="40" class="fill-accent-light origin-center" />
    <text
      x={@x}
      y={@y}
      class="font-iosevka text-8xl -translate-x-1/2 -translate-y-3/4 fill-blackish dark:fill-blackish-invert"
    >
      <%= @name %>
    </text>
    """
  end

  defp svg_path_to_server(assigns) do
    ~H"""
    <path
      id={@id}
      d={curve_coords({@my_x, @my_y}, {@x, @y}, 300)}
      stroke-dasharray="100,100"
      class="stroke-primary dark:stroke-whiteish opacity-60"
      stroke-width="15"
      stroke-linecap="round"
      fill="transparent"
    />
    """
  end

  def map_with_locations(assigns) do
    assigns =
      assigns
      |> assign(:all_locations, @locations)
      |> assign_new(:my_location, fn -> {41.0197, 28.9757} end)
      |> assign_new(:class, fn -> "" end)
      |> update(:class, &"relative #{&1}")

    ~H"""
    <div class={@class}>
      <.world_map />
      <svg class="absolute top-0 w-full boxed-transforms" viewBox="400 0 5671 2700">
        <defs>
          <path id="segment" d={svg_pie_slice_path(40, 360 / length(@databases))} />
          <symbol id="my-location" viewBox="0 0 36 36">
            <path
              d="M14,0 C21.732,0 28,5.641 28,12.6 C28,23.963 14,36 14,36 C14,36 0,24.064 0,12.6 C0,5.641 6.268,0 14,0 Z"
              fill="#fbb040"
            />
            <circle class="fill-primary" fill-rule="nonzero" cx="14" cy="14" r="7" />
          </symbol>
        </defs>
        <%= with {my_x, my_y} <- geo_coords_to_svg(@my_location) do %>
          <%= for {server, location} <- @relays,
                  {x, y} = geo_coords_to_svg(@all_locations[location]) do %>
            <g>
              <.svg_path_to_server x={x} y={y} my_x={my_x} my_y={my_y} id={"path-" <> location} />
              <.svg_server_node x={x} y={y} name={location} />

              <%= if @state not in [:ready, :complete]  do %>
                <%= for {db, i} <- Enum.with_index(@databases) do %>
                  <g>
                    <use
                      id={"node-#{location}-#{db}"}
                      xlink:href="#segment"
                      fill="#fbb040"
                      transform-origin="0 40"
                      transform={"rotate(#{360 / length(@databases) * i}) scale(1)"}
                    />
                    <animateMotion
                      id={"move-to-#{location}-#{db}"}
                      xlink:href={"#node-#{location}-#{db}"}
                      dur={ms(@animations.distribution)}
                      begin="indefinite"
                      calcMode="linear"
                      repeatCount="1"
                      fill="freeze"
                      phx-hook="TriggerAnimation"
                      data-start-phase="distribution"
                    >
                      <mpath xlink:href={"#path-#{location}"} />
                    </animateMotion>
                    <%= if @state == :received do %>
                      <animateTransform
                        additive="sum"
                        id={"pulse-#{location}-#{db}"}
                        xlink:href={"#node-#{location}-#{db}"}
                        begin="indefinite"
                        attributeName="transform"
                        type="scale"
                        dur="1s"
                        repeatDur={ms(@animation_latency_map[server][db])}
                        values="1;3"
                        repeatCount="indefinite"
                        phx-hook="TriggerAnimation"
                        data-start-phase="execution"
                      />
                      <animate
                        id={"pulse-opacity-#{location}-#{db}"}
                        xlink:href={"#node-#{location}-#{db}"}
                        begin="indefinite"
                        attributeName="opacity"
                        dur="1s"
                        repeatDur={ms(@animation_latency_map[server][db])}
                        values="1;0"
                        repeatCount="indefinite"
                        phx-hook="TriggerAnimation"
                        data-start-phase="execution"
                      />
                      <set
                        id={"segment-color-#{location}-#{db}"}
                        xlink:href={"#node-#{location}-#{db}"}
                        attributeName="fill"
                        to={get_segment_fill_color(@latency_map[server][db])}
                        begin="indefinite"
                        dur="indefinite"
                        fill="freeze"
                        phx-hook="TriggerAnimation"
                        data-start-phase="execution"
                        data-delay={ms(@animation_latency_map[server][db])}
                      />

                      <animateMotion
                        id={"move-from-#{location}-#{db}"}
                        xlink:href={"#node-#{location}-#{db}"}
                        dur={ms(@animations.collection)}
                        begin="indefinite"
                        keyPoints="1;0"
                        keyTimes="0;1"
                        calcMode="linear"
                        repeatCount="1"
                        fill="freeze"
                        phx-hook="TriggerAnimation"
                        data-start-phase="collection"
                      >
                        <mpath xlink:href={"#path-#{location}"} />
                      </animateMotion>

                      <animate
                        xlink:href={"#node-#{location}-#{db}"}
                        begin={"move-from-#{location}-#{db}.end + 0s"}
                        attributeName="opacity"
                        dur={ms(@animations.collection)}
                        values="1;1;0"
                        keyTimes="0;0.75;1"
                        calcMode="linear"
                        repeatCount="1"
                        fill="freeze"
                      />
                    <% end %>
                  </g>
                <% end %>
              <% end %>
            </g>
          <% end %>

          <use
            href="#my-location"
            x={my_x}
            y={my_y}
            width="200"
            height="200"
            class="-translate-x-1/2 -translate-y-full"
          />
        <% end %>
      </svg>
    </div>
    """
  end

  defp get_segment_fill_color({:ok, _}), do: "#22c55e"
  defp get_segment_fill_color(_), do: "#ef4444"

  defp assign_map_classes(svg, classes) do
    String.replace_leading(svg, "<svg", ~s|<svg class="#{classes}"|)
  end

  defp svg_pie_slice_path({cx, cy} \\ {0, 0}, radius, sweep_angle, start_angle \\ -90) do
    start_angle_rad = start_angle * :math.pi() / 180
    sweep_angle_rad = sweep_angle * :math.pi() / 180

    x1 = cx + radius * :math.cos(start_angle_rad)
    y1 = cy + radius * :math.sin(start_angle_rad)
    x2 = cx + radius * :math.cos(start_angle_rad + sweep_angle_rad)
    y2 = (cy + radius * :math.sin(start_angle_rad + sweep_angle_rad)) |> Float.round(4)

    [
      # Starting point in the circle center
      "M#{cx},#{cy} ",
      # Line towards the first point on the curve
      "L#{x1},#{y1} ",
      # Arc from the first to the second point
      "A#{radius},#{radius} 0 0,1 #{x2},#{y2}",
      # Close the shape (line from the second point to the circle center)
      "Z"
    ]
    |> IO.iodata_to_binary()
  end

  defp geo_to_natural_cartesian({lat, lon}) do
    # Coordinates to radians
    lambda = pi() / 180 * lon
    psi = pi() / 180 * lat

    # https://en.wikipedia.org/wiki/Natural_Earth_projection
    l =
      0.870700 - 0.131979 * pow(psi, 2) - 0.013791 * pow(psi, 4) + 0.003971 * pow(psi, 10) -
        0.001529 * pow(psi, 12)

    # x is [-2.73539, 2.73539]
    x = l * lambda

    # y is [-1.42239, 1.42239]
    y =
      psi *
        (1.007226 + 0.015085 * pow(psi, 2) - 0.044475 * pow(psi, 6) + 0.028874 * pow(psi, 8) -
           0.005916 * pow(psi, 10))

    {x, y}
  end

  defp natural_cartesian_to_svg({nat_x, nat_y}, svg_width \\ 6071, svg_height \\ 3162) do
    x = (nat_x + 2.73539) / 5.47078 * svg_width
    y = -(nat_y - 1.42239) / 2.84478 * svg_height

    {x, y}
  end

  defp geo_coords_to_svg(coords),
    do: coords |> geo_to_natural_cartesian() |> natural_cartesian_to_svg()

  defp curve_coords({x1, y1}, {x2, y2}, control_point_offset) do
    # midpoints
    mp_x = (x2 + x1) * 0.5
    mp_y = (y2 + y1) * 0.5

    # angle
    theta = :math.atan2(y2 - y1, x2 - x1) + :math.pi() / 2

    modifier = if theta < 0, do: 1, else: -1

    # control point
    cp_x = mp_x + control_point_offset * :math.cos(theta) * modifier
    cp_y = mp_y + control_point_offset * :math.sin(theta) * modifier

    "M#{x1} #{y1} Q#{cp_x} #{cp_y} #{x2} #{y2}"
  end

  defp ms(number), do: "#{number}ms"
end
