defmodule SatoriWeb.TargetLive.Index do
  use SatoriWeb, :live_view

  alias Satori.Targets
  alias Satori.Targets.Target

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :targets, list_targets())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Target")
    |> assign(:target, Targets.get_target!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Target")
    |> assign(:target, %Target{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Targets")
    |> assign(:target, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    target = Targets.get_target!(id)
    {:ok, _} = Targets.delete_target(target)

    {:noreply, assign(socket, :targets, list_targets())}
  end

  defp list_targets do
    Targets.list_targets()
  end
end
