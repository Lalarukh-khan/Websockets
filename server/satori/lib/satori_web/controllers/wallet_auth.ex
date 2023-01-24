defmodule SatoriWeb.WalletAuth do
  @moduledoc """
  Satori.WalletAuth represents a process whereby the client
  authenticates through signature verification.

  Upon connection the client will provide it's wallet public key,
  a message that it signed which is the current datetime, which
  must be within 5 seconds of what the server thinks is now, and a
  signature the server will then verify the signature and if it is
  valid, authenticate the client (not sure exactly what that means).
  """
  use Timex
  import Plug.Conn
  import Phoenix.Controller

  alias Satori.Wallets
  alias SatoriWeb.Router.Helpers, as: Routes
  # use DateTime

  @max_age 60 * 60 * 24 * 60
  @remember_me_cookie "_satori_web_user_remember_me"
  @remember_me_options [sign: true, max_age: @max_age, same_site: "Lax"]



  #Hari — Today at 3:07 PM
  #while I was looking through the code and executing, I found that login flow is broken.
  #And I narrowed down the problem to plugs in pipeline. When the user has session token,
  #current user is set. But in the next plug, you are trying to access wallet token and
  #setting the current user to nil if no wallet token is found. You may want to check for
  #wallet token only if current user is nil.
  #In the router where plugs and pipelines are implemented
  #plug(:fetch_current_user)
  #plug(:fetch_current_wallet)
  #Definition of fetch current wallet plug should be updated
  def fetch_current_wallet(conn, _opts) do
    {wallet_token, conn} = ensure_wallet_token(conn)
    user = wallet_token && Wallets.get_wallet_by_session_token(wallet_token)
    assign(conn, :current_user, user)
  end

  def log_in_wallet(conn, wallet, params \\ %{}) do
    token = Wallets.generate_wallet_session_token(wallet)
    IO.inspect(token)
    user_return_to = get_session(conn, :user_return_to)

    conn
    |> renew_session()
    |> put_session(:wallet_token, token)
    |> put_session(:live_socket_id, "wallets_sessions:#{Base.url_encode64(token)}")
    |> maybe_write_remember_me_cookie(token, params)
    |> redirect(to: user_return_to || signed_in_path(conn))
  end

  def log_out_wallet(conn) do
    wallet_token = get_session(conn, :wallet_token)
    wallet_token && Wallets.delete_session_token(wallet_token)

    if live_socket_id = get_session(conn, :live_socket_id) do
      SatoriWeb.Endpoint.broadcast(live_socket_id, "disconnect", %{})
    end

    conn
    |> renew_session()
    |> delete_resp_cookie(@remember_me_cookie)
    |> redirect(to: "/")
  end

  defp maybe_write_remember_me_cookie(conn, token, %{"remember_me" => "true"}) do
    put_resp_cookie(conn, @remember_me_cookie, token, @remember_me_options)
  end

  defp maybe_write_remember_me_cookie(conn, _token, _params) do
    conn
  end

  defp renew_session(conn) do
    conn
    |> configure_session(renew: true)
    |> clear_session()
  end

  defp signed_in_path(_conn), do: "/"

  defp ensure_wallet_token(conn) do
    if wallet_token = get_session(conn, :wallet_token) do
      {wallet_token, conn}
    else
      conn = fetch_cookies(conn, signed: [@remember_me_cookie])

      if wallet_token = conn.cookies[@remember_me_cookie] do
        {wallet_token, put_session(conn, :wallet_token, wallet_token)}
      else
        {nil, conn}
      end
    end
  end


  # TODO: finish this - coppied from user_auth.ex
  @doc """
  Used for routes that require the user to be authenticated.

  we need to ensure only those wallets that are authenticated
  and assigned to a stream can publish to it. would that be
  ensured here?
  """
  # is conn even used since it's websockets?
  def require_authenticated_wallet(conn, _opts) do
    # what should this be for wallet authentication?
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "You must log in to access this page.")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end

  def verify?(message, signature, public_key) do
    messageIsRecent(message) && Satori.Wallets.Signature.verify!(
      message, signature, public_key)
  end

  # message should look like this: "2022-08-01 17:28:44.748691"
  defp messageIsRecent(message, ago \\ -60*60*24) do
    {:ok, compare} = Timex.parse(message, "%Y-%m-%d %H:%M:%S.%f", :strftime)
    messageTime = DateTime.from_naive!(compare, "Etc/UTC")

    {:gt, :gt} ==
      {DateTime.compare(Timex.now(), messageTime),
       DateTime.compare(messageTime, Timex.shift(Timex.now(), seconds: ago))}
  end
end
