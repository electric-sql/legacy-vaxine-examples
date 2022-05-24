defmodule AdvancedCounter.Repos.Antidote do
  use Ecto.Repo,
    otp_app: :advanced_counter,
    adapter: Vax.Adapter
end
