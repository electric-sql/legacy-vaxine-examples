defmodule AdvancedCounterWeb.RelayIntegration do
  @database_list ["cloudsql", "cockroach"]

  @spec stream_counter_increment(list(String.t()), list(String.t()), String.t()) :: Enumerable.t()
  def stream_counter_increment(servers, databases \\ @database_list, id) do
    pairs = for x <- servers, y <- databases, do: {x, y}

    Task.async_stream(pairs, fn {server, db} -> increment_one_counter(server, db, id) end,
      max_concurrency: length(pairs),
      ordered: true,
      on_timeout: :kill_task
    )
    |> Stream.zip(pairs)
    |> Stream.map(fn
      {{:ok, response}, _} -> response
      {{:exit, reason}, {server, db}} -> {server, db, {:error, "Network error: #{reason}"}}
    end)
  end

  def increment_counter(server, databases \\ @database_list, id) when is_binary(id) do
    Enum.map(databases, &increment_one_counter(server, &1, id))
  end

  defp increment_one_counter(server, database, id) when database in @database_list do
    Finch.build(:post, "#{server}/api/increment/#{database}/#{id}")
    |> Finch.request(Relay)
    |> case do
      {:ok, %Finch.Response{body: body, status: 200}} ->
        %{"write_latency" => latency} = Jason.decode!(body)
        {server, database, {:ok, latency}}

      {:ok, %Finch.Response{body: body, status: 503}} ->
        %{"error" => error} = Jason.decode!(body)
        {server, database, {:error, error}}

      {:error, %Mint.TransportError{reason: reason}} ->
        {server, database, {:error, "Network error: #{reason}"}}
    end
  end
end
