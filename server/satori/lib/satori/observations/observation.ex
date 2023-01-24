defmodule Satori.Observations.Observation do
  use Ecto.Schema
  import Ecto.Changeset
  alias Satori.Streams.Stream
  alias Satori.Targets.Target

  @fields ~w(stream_id target_id value)a
  @required ~w(stream_id target_id value)a

  schema "observations" do
    field :value, :string

    belongs_to :stream, Stream
    belongs_to :target, Target

    timestamps()
  end

  @doc false
  def changeset(observation, attrs) do
    observation
    |> cast(attrs, @fields)
    |> validate_required(@required)
  end
end
