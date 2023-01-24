defmodule SatoriPubsubWeb.StreamChannel do
  use Phoenix.Channel

  def join("stream:123", _message, socket) do
    {:ok, socket}
  end

  def join("stream:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("new_data", %{"body" => body}, socket) do
    # save to db / memory storage
    broadcast!(socket, "new_data", %{body: body})
    {:noreply, socket}
  end
end
