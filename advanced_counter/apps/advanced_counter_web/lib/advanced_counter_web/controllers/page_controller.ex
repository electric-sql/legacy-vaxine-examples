defmodule AdvancedCounterWeb.PageController do
  use AdvancedCounterWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
