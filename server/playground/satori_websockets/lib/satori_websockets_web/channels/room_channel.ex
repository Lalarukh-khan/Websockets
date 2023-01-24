defmodule SatoriWebsocketsWeb.RoomChannel do
  use SatoriWebsocketsWeb, :channel
  use Phoenix.Channel

  def join("room:lobby", _message, socket) do
    {:ok, socket}
  end

  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("message:add", %{"message" => body}, socket) do
    room_id = socket.assigns[:room_id]
    broadcast!(socket, "room:#{room_id}:new_message", %{body: body})
    IO.puts("Received Message from Client: #{body}")
    # {:reply, {:ok, %{kind: "public", from: "server", body: body}}, socket}
    {:reply, {:ok, %{from: "server", body: body}}, socket}
    # {:reply, :ok, socket}
  end

def handle_in(nil, %{event: "phx_leave"}, socket) do
    # reply = %Reply{
    #   ref: ref,
    #   join_ref: join_ref,
    #   topic: topic,
    #   status: :ok,
    #   payload: %{}
    # }
    IO.puts("Client just disconnected")
    {:reply, :ok, socket}
  end
  # def handle_in("new_msg", %{"body" => body}, socket) do
  #   broadcast!(socket, "new_msg", %{body: body})
  #   {:noreply, socket}
  # end

  # def handle_in("new_msg", %{"body" => body}, socket) do
  #   broadcast socket, "new_msg", %{body: body}
  #   {:noreply, socket}
  # end

  @impl true
  def join("room:lobby", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
