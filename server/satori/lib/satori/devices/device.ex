defmodule Satori.Devices.Device do
  use Ecto.Schema
  import Ecto.Changeset
  alias Satori.Wallets.Wallet
  alias Satori.Subscribers.Subscriber

  @fields ~w(name cpu disk bandwidth ram wallet_id)a
  @required ~w(disk ram wallet_id)a

  schema "devices" do
    field :bandwidth, :string
    field :cpu, :string
    field :disk, :integer
    field :name, :string
    field :ram, :integer

    belongs_to :wallet, Wallet
    has_many :subscriber, Subscriber

    timestamps()
  end

  @doc false
  def changeset(device, attrs) do
    device
    |> cast(attrs, @fields)
    |> validate_required(@required)
  end
end
