defmodule Satori.Subscribers.Subscriber do
  use Ecto.Schema
  import Ecto.Changeset
  alias Satori.Device.Device
  alias Satori.Stream.Stream
  alias Satori.Target.Target

  @fields ~w(stream_id device_id target_id)a
  @required ~w(stream_id device_id target_id)a

  schema "subscribers" do
    belongs_to :device, Device
    belongs_to :stream, Stream
    belongs_to :target, Target

    timestamps()
  end

  @doc false
  def changeset(subscriber, attrs) do
    subscriber
    |> cast(attrs, @fields)
    |> validate_required(@required)
  end
end
