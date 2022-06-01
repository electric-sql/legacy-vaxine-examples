defmodule AdvancedCounterRelay.IncrementController do
  use AdvancedCounterRelay, :controller
  require Logger

  @acceptable_dbs ["cloudsql", "cockroach", "antidote"]

  @spec increment(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def increment(conn, %{"database" => db, "counter_id" => counter_id})
      when db in @acceptable_dbs do
    case :timer.tc(&AdvancedCounter.increment/2, [db, counter_id]) do
      {latency, {:ok, _}} ->
        json(conn, %{status: :ok, database: db, write_latency: latency / 1000})

      {_, {:error, reasons}} ->
        Logger.error("""
        Error while incrementing counter `#{counter_id}` in db #{db}:
          #{inspect(reasons)}
        """)

        conn
        |> put_status(503)
        |> json(%{status: :error, database: db, error: "Couldn't increment the counter"})
    end
  rescue
    e ->
      Logger.error("""
      Error while incrementing counter `#{counter_id}` in db #{db}:
        #{inspect(e)}
      """)

      conn
      |> put_status(503)
      |> json(%{status: :error, database: db, error: "Couldn't connect to the database"})
  end

  def increment(conn, _) do
    conn
    |> put_status(:bad_request)
    |> json(%{status: :error, database: "Must be one of: " <> Enum.join(@acceptable_dbs, ", ")})
  end
end
