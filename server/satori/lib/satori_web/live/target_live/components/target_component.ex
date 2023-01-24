defmodule SatoriWeb.TargetLive.Components.TargetComponent do
  use SatoriWeb, :live_component
  alias Satori.Targets

  @impl true
  def handle_event("delete-target", %{"target_id" => target_id}, socket) do
    target = Targets.get_target!(target_id)

    Targets.delete_target(target)

    {:noreply,
      socket
      |> assign(:targets, Targets.list_targets())
      |> put_flash(:info, "Deleted #{target.name}.")
      |> push_redirect(to: socket.assigns.return_to)
    }
  end
end
