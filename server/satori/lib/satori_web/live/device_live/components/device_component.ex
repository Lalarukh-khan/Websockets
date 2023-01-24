defmodule SatoriWeb.DeviceLive.Components.DeviceComponent do
  use SatoriWeb, :live_component
  alias Satori.Devices

  @impl true
  def handle_event("delete-device", %{"device_id" => device_id}, socket) do
    device = Devices.get_device!(device_id)

    Devices.delete_device(device)

    {:noreply,
      socket
      |> assign(:devices, Devices.list_devices())
      |> put_flash(:info, "Deleted #{device.name}.")
      |> push_redirect(to: socket.assigns.return_to)
    }
  end
end
