defmodule SatoriWeb.PinLive.Index do
  use SatoriWeb, :live_view

  alias Satori.Pins
  alias Satori.Pins.Pin

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :pins, list_pins())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Pin")
    |> assign(:pin, Pins.get_pin!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Pin")
    |> assign(:pin, %Pin{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Pins")
    |> assign(:pin, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    pin = Pins.get_pin!(id)
    {:ok, _} = Pins.delete_pin(pin)

    {:noreply, assign(socket, :pins, list_pins())}
  end

  defp list_pins do
    Pins.list_pins()
  end
end
