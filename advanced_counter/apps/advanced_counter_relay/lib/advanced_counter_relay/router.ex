defmodule AdvancedCounterRelay.Router do
  use AdvancedCounterRelay, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", AdvancedCounterRelay do
    pipe_through :api

    post "/increment/:database/:counter_id", IncrementController, :increment
  end
end
