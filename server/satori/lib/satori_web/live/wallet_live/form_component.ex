defmodule SatoriWeb.WalletLive.FormComponent do
  use SatoriWeb, :live_component

  alias Satori.Wallets

  @impl true
  def update(%{wallet: wallet} = assigns, socket) do
    changeset = Wallets.change_wallet(wallet)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"wallet" => wallet_params}, socket) do
    changeset =
      socket.assigns.wallet
      |> Wallets.change_wallet(wallet_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"wallet" => wallet_params}, socket) do
    save_wallet(socket, socket.assigns.action, wallet_params)
  end

  defp save_wallet(socket, :edit, wallet_params) do
    case Wallets.update_wallet(socket.assigns.wallet, wallet_params) do
      {:ok, _wallet} ->
        {:noreply,
         socket
         |> put_flash(:info, "Wallet updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_wallet(socket, :new, wallet_params) do
    case Wallets.create_wallet(wallet_params) do
      {:ok, _wallet} ->
        {:noreply,
         socket
         |> put_flash(:info, "Wallet created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
