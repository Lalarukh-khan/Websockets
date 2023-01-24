defmodule SatoriWeb.ObservationLive.FormComponent do
  use SatoriWeb, :live_component

  alias Satori.Observations

  @impl true
  def update(%{observation: observation} = assigns, socket) do
    changeset = Observations.change_observation(observation)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"observation" => observation_params}, socket) do
    changeset =
      socket.assigns.observation
      |> Observations.change_observation(observation_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"observation" => observation_params}, socket) do
    save_observation(socket, socket.assigns.action, observation_params)
  end

  defp save_observation(socket, :edit, observation_params) do
    case Observations.update_observation(socket.assigns.observation, observation_params) do
      {:ok, _observation} ->
        {:noreply,
         socket
         |> put_flash(:info, "Observation updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_observation(socket, :new, observation_params) do
    case Observations.create_observation(observation_params) do
      {:ok, _observation} ->
        {:noreply,
         socket
         |> put_flash(:info, "Observation created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
