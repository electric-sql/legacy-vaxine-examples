defmodule AdvancedCounterRelay.IncrementControllerTest do
  use AdvancedCounterRelay.ConnCase

  test "should return errors when request made for unknown DB", %{conn: conn} do
    conn = post(conn, Routes.increment_path(conn, :increment, "unknown", "1"))

    assert json_response(conn, 400) == %{
             "status" => "error",
             "database" => "Must be one of: cloudsql, cockroach, antidote"
           }
  end

  test "should increment the counter for the DB and return the timing", %{conn: conn} do
    conn = post(conn, Routes.increment_path(conn, :increment, "cloudsql", "1"))

    assert %{
             "status" => "ok",
             "database" => "cloudsql",
             "write_latency" => latency
           } = json_response(conn, 200)

    assert latency > 0
    assert latency < 100
  end
end
