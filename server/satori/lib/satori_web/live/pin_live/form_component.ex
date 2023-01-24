defmodule SatoriWeb.PinLive.FormComponent do
  use SatoriWeb, :live_component

  alias Satori.Pins

  @impl true
  def update(%{pin: pin} = assigns, socket) do
    changeset = Pins.change_pin(pin)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"pin" => pin_params}, socket) do
    changeset =
      socket.assigns.pin
      |> Pins.change_pin(pin_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"pin" => pin_params}, socket) do
    save_pin(socket, socket.assigns.action, pin_params)
  end

  defp save_pin(socket, :edit, pin_params) do
    case Pins.update_pin(socket.assigns.pin, pin_params) do
      {:ok, _pin} ->
        {:noreply,
         socket
         |> put_flash(:info, "Pin updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_pin(socket, :new, pin_params) do
    case Pins.create_pin(pin_params) do
      {:ok, _pin} ->
        {:noreply,
         socket
         |> put_flash(:info, "Pin created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
