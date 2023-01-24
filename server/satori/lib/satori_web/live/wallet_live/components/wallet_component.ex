defmodule SatoriWeb.WalletLive.Components.WalletComponent do
  use SatoriWeb, :live_component
  alias Satori.Wallets

  @impl true
  def handle_event("delete-wallet", %{"wallet_id" => wallet_id}, socket) do
    wallet = Wallets.get_wallet!(wallet_id)

    Wallets.delete_wallet(wallet)

    {:noreply,
      socket
      |> assign(:wallets, Wallets.list_wallets())
      |> put_flash(:info, "Deleted #{wallet.name}.")
      |> push_redirect(to: socket.assigns.return_to)
    }
  end
end
