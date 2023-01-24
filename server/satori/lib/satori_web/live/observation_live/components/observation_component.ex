defmodule SatoriWeb.ObservationLive.Components.ObservationComponent do
  use SatoriWeb, :live_component
  alias Satori.Observations

  @impl true
  def handle_event("delete-observation", %{"observation_id" => observation_id}, socket) do
    observation = Observations.get_observation!(observation_id)

    Observations.delete_observation(observation)

    {:noreply,
      socket
      |> assign(:observations, Observations.list_observations())
      |> put_flash(:info, "Deleted #{observation.name}.")
      |> push_redirect(to: socket.assigns.return_to)
    }
  end
end
