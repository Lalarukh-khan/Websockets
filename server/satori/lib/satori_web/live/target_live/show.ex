defmodule SatoriWeb.TargetLive.Show do
  use SatoriWeb, :live_view

  alias Satori.Targets

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:target, Targets.get_target!(id))}
  end

  defp page_title(:show), do: "Show Target"
  defp page_title(:edit), do: "Edit Target"
end
