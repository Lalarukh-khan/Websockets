defmodule SatoriPubsubWeb.PageController do
  use SatoriPubsubWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
