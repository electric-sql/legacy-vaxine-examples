defmodule Counters.Repo do
  use Ecto.Repo,
    otp_app: :basic_counter,
    adapter: Ecto.Adapters.Postgres
end
