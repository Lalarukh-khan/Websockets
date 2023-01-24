defmodule Satori.Wallets.WalletToken do
  use Ecto.Schema
  import Ecto.Query
  alias Satori.Wallets.WalletToken

  #@hash_algorithm :sha256
  @rand_size 32

  # It is very important to keep the reset password token expiry short,
  # since someone with access to the email may take over the account.
  #@reset_password_validity_in_days 1
  #@confirm_validity_in_days 7
  #@change_email_validity_in_days 7
  @session_validity_in_days 60

  schema "wallets_tokens" do
    field(:token, :binary)
    field(:context, :string)
    field(:sent_to, :string)
    belongs_to(:wallet, Satori.Wallets.Wallet)

    timestamps(updated_at: false)
  end

  def build_session_token(wallet) do
    token = :crypto.strong_rand_bytes(@rand_size)
    {token, %WalletToken{token: token, context: "session", wallet_id: wallet.id}}
  end

  def verify_session_token_query(token) do
    query =
      from(token in token_and_context_query(token, "session"),
        join: wallet in assoc(token, :wallet),
        where: token.inserted_at > ago(@session_validity_in_days, "day"),
        select: wallet
      )

    {:ok, query}
  end

  def token_and_context_query(token, context) do
    from(WalletToken, where: [token: ^token, context: ^context])
  end
end
