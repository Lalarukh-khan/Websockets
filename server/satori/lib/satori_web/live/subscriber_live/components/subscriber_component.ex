defmodule SatoriWeb.SubscriberLive.Components.SubscriberComponent do
  use SatoriWeb, :live_component
  alias Satori.Subscribers

  @impl true
  def handle_event("delete-subscriber", %{"subscriber_id" => subscriber_id}, socket) do
    subscriber = Subscribers.get_subscriber!(subscriber_id)

    Subscribers.delete_subscriber(subscriber)

    {:noreply,
      socket
      |> assign(:subscribers, Subscribers.list_subscribers())
      |> put_flash(:info, "Deleted #{subscriber.name}.")
      |> push_redirect(to: socket.assigns.return_to)
    }
  end
end
