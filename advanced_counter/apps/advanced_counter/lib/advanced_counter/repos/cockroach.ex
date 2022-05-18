defmodule AdvancedCounter.Repos.Cockroach do
  use Ecto.Repo,
    otp_app: :advanced_counter,
    adapter: Ecto.Adapters.Postgres
end
