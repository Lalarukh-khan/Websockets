defmodule SatoriWeb.TargetLive.FormComponent do
  use SatoriWeb, :live_component

  alias Satori.Targets

  @impl true
  def update(%{target: target} = assigns, socket) do
    changeset = Targets.change_target(target)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"target" => target_params}, socket) do
    changeset =
      socket.assigns.target
      |> Targets.change_target(target_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"target" => target_params}, socket) do
    save_target(socket, socket.assigns.action, target_params)
  end

  defp save_target(socket, :edit, target_params) do
    case Targets.update_target(socket.assigns.target, target_params) do
      {:ok, _target} ->
        {:noreply,
         socket
         |> put_flash(:info, "Target updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_target(socket, :new, target_params) do
    case Targets.create_target(target_params) do
      {:ok, _target} ->
        {:noreply,
         socket
         |> put_flash(:info, "Target created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
