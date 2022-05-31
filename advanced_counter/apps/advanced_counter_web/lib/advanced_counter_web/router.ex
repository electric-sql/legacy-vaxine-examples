defmodule AdvancedCounterWeb.Router do
  use AdvancedCounterWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {AdvancedCounterWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug AdvancedCounterWeb.Plugs.ContentSecurityPolicy
  end

  scope "/", AdvancedCounterWeb do
    pipe_through :browser

    live "/", LatencyMatrixLive.Index, :index
  end
end
