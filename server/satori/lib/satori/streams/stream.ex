defmodule Satori.Streams.Stream do
  use Ecto.Schema
  import Ecto.Changeset
  alias Satori.Subscribers.Subscriber
  alias Satori.Wallets.Wallet
  alias Satori.Observations.Observation

  @fields ~w(wallet_id source_name name cadence sanctioned stream_id)a
  @required ~w(wallet_id source_name name)a

  schema "streams" do
    field :cadence, :string
    field :name, :string
    field :sanctioned, :boolean, default: false
    field :source_name, :string
    # This is the ID of the stream that this stream predicts,
    # if null this is a primary raw data stream,
    # if not null this is a prediction stream
    # has_one :stream, __MODULE__, foreign_key: :stream_id

    has_many :subscriber, Subscriber
    has_many :observation, Observation
    has_many :stream, Satori.Streams.Stream
    belongs_to :prediction_of_stream, Satori.Streams.Stream
    belongs_to :wallet, Wallet
    #field :stream_id, :integer # prediction of stream

    timestamps()
  end

  @doc false
  def changeset(stream, attrs) do
    stream
    |> cast(attrs, @fields)
    |> validate_required(@required)
  end
end
