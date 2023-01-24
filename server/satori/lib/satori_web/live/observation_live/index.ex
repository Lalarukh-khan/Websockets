defmodule SatoriWeb.ObservationLive.Index do
  use SatoriWeb, :live_view

  alias Satori.Observations
  alias Satori.Observations.Observation

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :observations, list_observations())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Observation")
    |> assign(:observation, Observations.get_observation!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Observation")
    |> assign(:observation, %Observation{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Observations")
    |> assign(:observation, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    observation = Observations.get_observation!(id)
    {:ok, _} = Observations.delete_observation(observation)

    {:noreply, assign(socket, :observations, list_observations())}
  end

  defp list_observations do
    Observations.list_observations()
  end
end
