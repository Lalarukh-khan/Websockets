defmodule SatoriWeb.WalletRegistrationController do
  @moduledoc """
    TODO: recreate this entire file in graphql since
          controllers are browser (GET, POST) specific
  """
  use SatoriWeb, :controller

  alias Satori.Wallets
  alias Satori.Wallets.Wallet
  alias SatoriWeb.WalletAuth

  def new(conn, _params) do
    # changeset = Accounts.change_user_registration(%User{})

    render(conn, "new.html", changeset: Wallets.change_wallet(%Wallet{}))
  end

  @doc """
  Creates a new wallet.
  """
  def create(conn, %{
        "wallet" =>
          %{"message" => message, "signature" => signature, "public_key" => public_key, "address" => address} = _user_params
      }) do
    case WalletAuth.verify?(message, signature, public_key) do
      true ->
        case Wallets.create_wallet(%{"public_key" => public_key, "address" => address}) do
          {:ok, wallet} ->
            conn
            |> put_flash(:info, "Wallet created successfully.")
            |> WalletAuth.log_in_wallet(wallet)

          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "new.html", changeset: changeset)
        end

      _ ->
        conn
            |> put_flash(:info, "Error Signature Verification failed.")
            |> render("new.html", changeset: Wallets.change_wallet(%Wallet{}))
    end
  end

end
