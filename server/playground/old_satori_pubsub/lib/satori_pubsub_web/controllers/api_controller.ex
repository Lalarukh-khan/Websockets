defmodule SatoriPubsubWeb.APIController do
  use SatoriPubsubWeb, :controller

  def create(conn, params) do
    # json(conn, %{data: params})
    json(conn, params)

  end

  def create2(conn, %{"user" => user}) do
    json(conn, %{data: user})
  end

end
