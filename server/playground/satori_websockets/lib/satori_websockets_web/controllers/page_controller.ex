defmodule SatoriWebsocketsWeb.PageController do
  use SatoriWebsocketsWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
