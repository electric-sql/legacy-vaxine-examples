defmodule CountersWeb.PageController do
  use CountersWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
