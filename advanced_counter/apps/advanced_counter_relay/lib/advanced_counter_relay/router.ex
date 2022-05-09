defmodule AdvancedCounterRelay.Router do
  use AdvancedCounterRelay, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", AdvancedCounterRelay do
    pipe_through :api
  end
end
