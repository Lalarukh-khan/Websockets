defmodule SatoriWeb.StreamLive.Components.StreamComponent do
  use SatoriWeb, :live_component
  alias Satori.Streams

  @impl true
  def handle_event("delete-stream", %{"stream_id" => stream_id}, socket) do
    stream = Streams.get_stream!(stream_id)

    Streams.delete_stream(stream)

    {:noreply,
      socket
      |> assign(:streams, Streams.list_streams())
      |> put_flash(:info, "Deleted #{stream.name}.")
      |> push_redirect(to: socket.assigns.return_to)
    }
  end
end
