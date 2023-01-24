defmodule Satori.Pins.Pin do
  use Ecto.Schema
  import Ecto.Changeset
  alias Satori.Streams.Stream
  alias Satori.Targets.Target
  alias Satori.Wallets.Wallet

  @fields ~w(wallet_id stream_id target_id ipns ipfs)a
  @required ~w(wallet_id stream_id target_id ipns ipfs)a

  schema "pins" do
    field :ipns, :string
    field :ipfs, :string

    belongs_to :stream, Stream
    belongs_to :wallet, Wallet
    belongs_to :target, Target

    timestamps()
  end

  @doc false
  def changeset(pin, attrs) do
    pin
    |> cast(attrs, @fields)
    |> validate_required(@required)
  end
end
