defmodule CountersWeb.Router do
  use CountersWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {CountersWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", CountersWeb do
    pipe_through :browser

    live "/", ReactionLive.Index, :index
  end
end
