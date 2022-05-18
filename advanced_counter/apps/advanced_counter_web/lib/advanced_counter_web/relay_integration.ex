defmodule AdvancedCounterWeb.RelayIntegration do
  @database_list ["cloudsql", "cockroach"]

  def increment_counter(databases \\ @database_list, id) when is_binary(id) do
    Enum.map(databases, &increment_one_counter(&1, id))
  end

  defp increment_one_counter(database, id) when database in @database_list do
    Finch.build(:post, "http://localhost:4001/api/increment/#{database}/#{id}")
    |> Finch.request(Relay)
    |> case do
      {:ok, %Finch.Response{body: body, status: 200}} ->
        %{"write_latency" => latency} = Jason.decode!(body)
        {database, {:ok, latency}}

      {:ok, %Finch.Response{body: body, status: 503}} ->
        %{"error" => error} = Jason.decode!(body)
        {database, {:error, error}}

      {:error, %Mint.TransportError{reason: reason}} ->
        {database, {:error, "Network error: #{reason}"}}
    end
  end
end
